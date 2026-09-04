-- Description -----------------------------------------------------------------------------
--
-- Floating and right terminals.
--
-- -----------------------------------------------------------------------------------------

local float = require("misc.float")

local M = {}

--------------------------------------------------------------------------------------------
--                                    Local Variables                                     --
--------------------------------------------------------------------------------------------

-- The `<Esc>` key sequence to send to the terminal.
local esc_key = vim.keycode("<Esc>")

-- Shell used exclusively by the terminals spawned from this module. It is intentionally
-- decoupled from `vim.o.shell` so that these terminals do not affect the global shell (e.g.,
-- `:!` commands and terminal jobs outside this file).
local terminal_shell = "nu"

-- State of the floating terminal.
M.floating_term = {
  buf          = nil, -- Buffer for the floating terminal.
  win          = nil, -- Window for the floating terminal.
  jobid        = nil, -- Job ID for the terminal process.
  backdrop_buf = nil, -- Buffer for the backdrop window.
  backdrop_win = nil, -- Window for the backdrop (padding).
}

-- State of the right terminal.
M.right_term = {
  buf   = nil, -- Buffer for the right terminal.
  win   = nil, -- Window for the right terminal.
  jobid = nil, -- Job ID for the terminal process.
}

--------------------------------------------------------------------------------------------
--                                    Local Functions                                     --
--------------------------------------------------------------------------------------------

--- If the shell is nushell, source the nano theme matching the current background.
---
--- @param jobid number|nil Terminal job ID.
local function send_nushell_theme(jobid)
  if not jobid or vim.fs.basename(terminal_shell) ~= "nu" then
    return
  end

  vim.fn.chansend(jobid, 'source ($nu.data-dir | path join "vendor/nano_active.nu")\n')
end

--- Map `<Esc>` in the terminal buffer `buf`: pressing it once sends it to the terminal after
--- 200 ms, and pressing it twice quickly exits to normal mode.
---
--- @param buf integer Terminal buffer.
--- @param get_jobid function Return the terminal job ID.
local function map_double_esc(buf, get_jobid)
  local timer = vim.uv.new_timer()

  vim.keymap.set(
    "t",
    "<Esc>",
    function()
      if timer:is_active() then
        timer:stop()
        vim.cmd.stopinsert()

        -- Consume the next keypress that would be sent to the terminal.
        vim.schedule(function() vim.fn.getchar(0) end)
      else
        timer:start(
          200,
          0,
          vim.schedule_wrap(
            function()
              local jobid = get_jobid()

              if jobid then
                vim.fn.chansend(jobid, esc_key)
              end
            end
          )
        )
      end

      return ""
    end,
    { buffer = buf, expr = true, silent = true }
  )
end

--- Toggle the floating terminal: close it when open, otherwise show it, creating the
--- terminal on the first call.
local function toggle_floating_terminal()
  local ft = M.floating_term

  if ft.win and vim.api.nvim_win_is_valid(ft.win) then
    float.close(ft)
    return
  end

  local is_new = not (ft.buf and vim.api.nvim_buf_is_valid(ft.buf))

  if is_new then
    ft.buf = vim.api.nvim_create_buf(false, true)
  end

  local width, height, row, col = float.centered(0.8, 0.8)

  local f = float.open(
    {
      buf          = ft.buf,
      width        = width,
      height       = height,
      row          = row,
      col          = col,
      backdrop_buf = ft.backdrop_buf,
    }
  )

  ft.win, ft.backdrop_win, ft.backdrop_buf = f.win, f.backdrop_win, f.backdrop_buf

  if is_new then
    ft.jobid = vim.fn.jobstart(
      terminal_shell,
      {
        term = true,
        on_exit = function()
          ft.jobid = nil
          vim.schedule(function() float.close(ft) end)
        end,
      }
    )

    send_nushell_theme(ft.jobid)
    vim.bo[ft.buf].filetype = "terminal"
    map_double_esc(ft.buf, function() return ft.jobid end)

    local group = vim.api.nvim_create_augroup("FloatingTerminal", { clear = true })

    -- Close the windows when the buffer is wiped out.
    vim.api.nvim_create_autocmd(
      "BufWipeout",
      {
        buf      = ft.buf,
        group    = group,
        callback = function() float.close(ft) end,
      }
    )

    -- Close the backdrop when the terminal window is closed by other means.
    vim.api.nvim_create_autocmd(
      "WinClosed",
      {
        group    = group,
        callback = function(args)
          if tonumber(args.match) == ft.win then
            ft.win = nil
            float.close(ft)
          end
        end,
      }
    )
  end

  vim.cmd.startinsert()
end

--- Toggle the right terminal: hide it when open, otherwise show it, creating the terminal
--- on the first call.
local function toggle_right_terminal()
  local rt = M.right_term

  if rt.win and vim.api.nvim_win_is_valid(rt.win) then
    vim.api.nvim_win_hide(rt.win)
    return
  end

  local is_new = not (rt.buf and vim.api.nvim_buf_is_valid(rt.buf))

  if is_new then
    rt.buf = vim.api.nvim_create_buf(false, true)
  end

  vim.cmd("botright 95vsplit")
  rt.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(rt.win, rt.buf)
  vim.wo[rt.win].cursorline = false

  if is_new then
    rt.jobid = vim.fn.jobstart(
      terminal_shell,
      {
        term    = true,
        on_exit = function() rt.jobid = nil end,
      }
    )

    send_nushell_theme(rt.jobid)
    vim.bo[rt.buf].filetype = "terminal"

    -- Window navigation from the terminal mode.
    for _, dir in ipairs({ { "h", "<Left>" }, { "j", "<Down>" }, { "k", "<Up>" }, { "l", "<Right>" } }) do
      vim.keymap.set(
        "t",
        { "<C-w>" .. dir[1], "<C-w>" .. dir[2] },
        "<C-\\><C-n><C-w>" .. dir[1],
        { buffer = rt.buf, silent = true }
      )
    end

    map_double_esc(rt.buf, function() return rt.jobid end)

    local group = vim.api.nvim_create_augroup("RightTerminal", { clear = true })

    -- Close the window when the buffer is wiped out.
    vim.api.nvim_create_autocmd(
      "BufWipeout",
      {
        buf      = rt.buf,
        group    = group,
        callback = function()
          if rt.win and vim.api.nvim_win_is_valid(rt.win) then
            vim.api.nvim_win_close(rt.win, true)
            rt.win = nil
          end
        end,
      }
    )

    -- Always start in insert mode when entering the terminal, and hide the cursorline.
    vim.api.nvim_create_autocmd(
      "BufEnter",
      {
        buf      = rt.buf,
        group    = group,
        callback = function()
          vim.wo.cursorline = false
          vim.cmd.startinsert()
        end,
      }
    )

    -- Quit Neovim when the right terminal would be the only remaining (non-floating)
    -- window. Floating windows are ignored because UI2 keeps a few of them open.
    vim.api.nvim_create_autocmd(
      "WinClosed",
      {
        group    = group,
        callback = function(args)
          if not (rt.buf and vim.api.nvim_buf_is_valid(rt.buf)) then
            return
          end

          local closing   = tonumber(args.match)
          local remaining = vim.tbl_filter(
            function(w)
              return w ~= closing and vim.api.nvim_win_get_config(w).relative == ""
            end,
            vim.api.nvim_list_wins()
          )

          if #remaining == 1 and vim.api.nvim_win_get_buf(remaining[1]) == rt.buf then
            -- Try a graceful quit. Neovim prompts if there are unsaved buffers.
            pcall(vim.cmd.qa)
          end
        end,
      }
    )
  end

  vim.cmd.startinsert()
end

--- Return the text of the current buffer, without trailing line breaks, ready to be sent
--- to a terminal.
local function buffer_text()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return table.concat(lines, "\n"):gsub("[\r\n]+$", "") .. "\n"
end

--- Return the visually selected text, without trailing line breaks, ready to be sent to a
--- terminal.
local function visual_text()
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
  return table.concat(lines, "\n"):gsub("[\r\n]+$", "") .. "\n"
end

--- Focus the right terminal window, if valid.
local function focus_right_term()
  if M.right_term.win and vim.api.nvim_win_is_valid(M.right_term.win) then
    vim.api.nvim_set_current_win(M.right_term.win)
  end
end

--------------------------------------------------------------------------------------------
--                                    Public Functions                                    --
--------------------------------------------------------------------------------------------

--- Send `text` to the right terminal.
---
--- @param text string Text to send.
function M.send_to_right_term(text)
  local rt = M.right_term

  if not (rt.jobid and vim.fn.jobwait({ rt.jobid }, 0)[1] == -1) then
    vim.notify("Right terminal is not running.", vim.log.levels.ERROR)
    return
  end

  vim.fn.chansend(rt.jobid, text)

  -- Keep the cursor at the end of the terminal, if the window is valid.
  if rt.win and vim.api.nvim_win_is_valid(rt.win) then
    vim.api.nvim_win_set_cursor(rt.win, { vim.api.nvim_buf_line_count(rt.buf), 0 })
  end
end

--- Setup the terminals.
function M.setup()
  vim.api.nvim_create_user_command("ToggleFloatingTerminal", toggle_floating_terminal, {})
  vim.api.nvim_create_user_command("ToggleRightTerminal",    toggle_right_terminal,    {})

  -- Keymaps -------------------------------------------------------------------------------

  local function term_map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
  end

  term_map({ "n", "t" }, "<F5>", toggle_floating_terminal,           "Toggle Floating Terminal")
  term_map("i",          "<F5>", "<Esc><Cmd>ToggleFloatingTerminal<CR>", "Toggle Floating Terminal")
  term_map({ "n", "t" }, "<F6>", toggle_right_terminal,              "Toggle Right Terminal")
  term_map("i",          "<F6>", "<Esc><Cmd>ToggleRightTerminal<CR>",    "Toggle Right Terminal")

  term_map(
    "n",
    "<Leader>bs",
    function() M.send_to_right_term(buffer_text()) end,
    "Send Buffer to Right Terminal"
  )

  term_map(
    "v",
    "<Leader>bs",
    function() M.send_to_right_term(visual_text()) end,
    "Send Selection to Right Terminal"
  )

  term_map(
    "n",
    "<Leader>bi",
    function()
      M.send_to_right_term(buffer_text())
      focus_right_term()
    end,
    "Send Buffer to Right Terminal with Focus"
  )

  term_map(
    "v",
    "<Leader>bi",
    function()
      M.send_to_right_term(visual_text())
      focus_right_term()
      vim.api.nvim_feedkeys(esc_key, "n", false)
    end,
    "Send Selection to Right Terminal with Focus"
  )
end

return M
