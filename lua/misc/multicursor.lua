-- Description -----------------------------------------------------------------------------
--
-- Support for the native multicursor (`:h multicursor`): state for the statusline and a
-- clipboard workaround.
--
-- Statusline state: Neovim reports the number of extra cursors and the follow mode (`q=`)
-- only through the 'showcmd' text ("=2× "). With UI2 enabled, that text arrives as a
-- `msg_showcmd` UI event handled by `vim._core.ui2.messages`. This module replaces that
-- handler: the state is parsed and stored here and nothing is drawn in the cmdline. Hence,
-- the pending command keys and the Visual selection size are not shown there either (the
-- statusline has its own Visual selection component).
--
-- Clipboard: registers are cursor-local, but 'clipboard' (unnamedplus) redirects the
-- unnamed register to `+`, and reading `+` calls the clipboard provider, which is global.
-- Hence, a put replayed at each cursor pastes the same text. While a multicursor session is
-- active, 'clipboard' is cleared so that yanks and puts use the cursor-local unnamed
-- register. The primary cursor's implicit yanks are still mirrored to `+` immediately, and
-- when the session ends the per-cursor yanks that Neovim joined into the unnamed register
-- are copied to `+`.
--
-- -----------------------------------------------------------------------------------------

local M = {
  -- Number of extra cursors as last reported by Neovim (0 when there is no multicursor
  -- session). This value can lag behind the actual cursors (see `M.cursors`).
  count = 0,

  -- Whether the follow mode (`q=`) is enabled.
  follow = false,
}

-- Namespace of the extmarks that track the multicursor positions.
local ns = vim.api.nvim_create_namespace("nvim.multicursor")

-- Return the number of extra cursors in the current buffer, obtained from the extmarks. This
-- is more accurate than `M.count`, which Neovim only refreshes when it redraws 'showcmd' and
-- hence may lag behind (e.g. right after clearing the cursors with CTRL-L).
function M.cursors()
  return #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
end

-- Parse the 'showcmd' text sent by Neovim ("=2× d") and update the state, redrawing the
-- statusline when it changes.
local function update(content)
  local text = content[1] and content[1][2] or ""
  local follow, count = text:match("^(=?)(%d+)×")

  count  = tonumber(count) or 0
  follow = follow == "="

  if count ~= M.count or follow ~= M.follow then
    M.count  = count
    M.follow = follow
    vim.schedule(function() vim.cmd.redrawstatus() end)
  end
end

-- Clipboard workaround state (see the description above).
local clipboard = {
  -- Value of 'clipboard' before the session started (nil when no session is active).
  saved = nil,

  -- Whether the unnamed register was yanked into during the session.
  yanked = false,

  -- Whether a clipboard update is already scheduled.
  pending = false,
}

-- Copy the unnamed register to the clipboard.
local function mirror_unnamed_register()
  vim.fn.setreg("+", vim.fn.getreg('"'), vim.fn.getregtype('"'))
end

local augroup = vim.api.nvim_create_augroup("misc.multicursor", { clear = true })

-- Multicursor session started: stop redirecting the unnamed register to the clipboard.
local function session_start()
  if clipboard.saved ~= nil then
    return
  end

  clipboard.saved  = vim.o.clipboard
  clipboard.yanked = false

  if clipboard.saved == "" then
    return
  end

  vim.o.clipboard = ""

  -- Mirror the implicit yanks to `+`, as 'clipboard' would have done. This event fires for
  -- the primary cursor and again for each replay at the other cursors. Hence, the update is
  -- coalesced into one scheduled clipboard call per command, which runs after the replays,
  -- when the primary cursor's registers are back in place.
  vim.api.nvim_create_autocmd(
    "TextYankPost",
    {
      group = augroup,
      callback = function()
        if vim.v.event.regname ~= "" then
          return
        end

        clipboard.yanked = true

        if clipboard.pending then
          return
        end

        clipboard.pending = true

        vim.schedule(
          function()
            clipboard.pending = false

            -- If the session ended meanwhile, `session_end` copies the joined yanks.
            if clipboard.saved ~= nil then
              mirror_unnamed_register()
            end
          end
        )
      end,
    }
  )
end

-- Multicursor session ended: restore 'clipboard' and copy the joined yanks to it.
local function session_end()
  if clipboard.saved == nil then
    return
  end

  local saved, yanked = clipboard.saved, clipboard.yanked
  clipboard.saved = nil

  if saved == "" then
    return
  end

  vim.api.nvim_clear_autocmds({ group = augroup })
  vim.o.clipboard = saved

  if yanked then
    -- Neovim joined the per-cursor yanks (linewise, in document order) into the unnamed
    -- register before ending the session. Copy the result to the clipboard. This is scheduled
    -- so that the session teardown finishes before calling the clipboard provider.
    vim.schedule(mirror_unnamed_register)
  end
end

-- Setup the multicursor state tracking and the clipboard workaround.
function M.setup()
  local ok, msgs = pcall(require, "vim._core.ui2.messages")

  if not ok then
    return
  end

  msgs.msg_showcmd = update

  local ok_mc, mcursor = pcall(require, "vim._core.mcursor")

  -- Neovim calls `vim._core.mcursor.enable(true)` when a session starts (first cursor) and
  -- `enable(false)` when it ends (last cursor removed), after joining the yanks.
  if ok_mc and type(mcursor.enable) == "function" then
    local enable = mcursor.enable

    mcursor.enable = function(on, ...)
      local result = enable(on, ...)

      if on then
        session_start()
      else
        session_end()
      end

      return result
    end
  end

  -- `{Visual}Q` places the cursors and enables the follow mode inside a Lua function
  -- (`vim._core.mcursor.visual`), and Neovim does not redraw 'showcmd' afterwards: the new
  -- state would only be reported at the next key press. Hence, wrap that function to update
  -- the state as soon as it returns.
  if ok_mc and type(mcursor.visual) == "function" then
    local visual = mcursor.visual

    mcursor.visual = function(...)
      local result = visual(...)

      M.count  = M.cursors()
      M.follow = true
      vim.schedule(function() vim.cmd.redrawstatus() end)

      return result
    end
  end
end

return M
