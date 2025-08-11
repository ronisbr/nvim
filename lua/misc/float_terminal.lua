-- Description -----------------------------------------------------------------------------
--
-- Implement a floating terminal.
--
-- -----------------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------------------
--                                    Local Variables                                     --
--------------------------------------------------------------------------------------------

-- Local state of the floating terminal.
local _floating_term = {
  buf = nil, -- ........................................... Buffer for the floating terminal
  win = nil  -- ........................................... Window for the floating terminal
}

local esc_timer = vim.loop.new_timer()
local esc_timer_active = false

--------------------------------------------------------------------------------------------
--                                    Local Functions                                     --
--------------------------------------------------------------------------------------------

-- Return the options for the floating terminal window.
local function _terminal_window_opts()
  -- Notice that we are removing two lines to take into account the status line and command
  -- line.
  local ui     = vim.api.nvim_list_uis()[1]
  local width  = math.floor(ui.width * 0.8)
  local height = math.floor((ui.height - 2) * 0.8)
  local col    = math.floor((ui.width - width) / 2)
  local row    = math.floor(((ui.height - 2) - height) / 2)

  local opts = {
    border   = "rounded",
    col      = col,
    height   = height,
    relative = "editor",
    row      = row,
    style    = "minimal",
    width    = width,
  }

  return opts
end

-- This function toggles the floating terminal.
local function _toggle_floating_terminal()
  if _floating_term.win ~= nil and vim.api.nvim_win_is_valid(_floating_term.win) then
    -- If the floating window is open, we hide it.
    vim.api.nvim_win_hide(_floating_term.win)
    return nil
  end

  -- Check if we need to create a new buffer for the terminal.
  if _floating_term.buf == nil or not vim.api.nvim_buf_is_valid(_floating_term.buf) then

    _floating_term.buf = vim.api.nvim_create_buf(false, true)

    -- Create the window.
    _floating_term.win = vim.api.nvim_open_win(
      _floating_term.buf,
      true,
      _terminal_window_opts()
    )

    vim.fn.jobstart(vim.o.shell, { term = true })
    vim.cmd.startinsert()

    -- Keymaps -----------------------------------------------------------------------------

    -- vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
    -- vim.keymap.set("t", "<Esc>", "<Esc>", { noremap = true, silent = true })

    vim.keymap.set('t', '<Esc>', function()
      if esc_timer_active then
        esc_timer:stop()
        esc_timer_active = false
        vim.cmd("stopinsert")  -- sai para modo normal
      else
        esc_timer:start(200, 0, function()
          esc_timer_active = false
          esc_timer:stop()
        end)
        esc_timer_active = true
        return "<esc>"  -- envia Esc para o terminal
      end
    end, { expr = true, noremap = true, silent = true })

    -- Autocmds ----------------------------------------------------------------------------

    -- Close the window if the buffer is deleted.
    vim.api.nvim_create_autocmd(
      "BufWipeout",
      {
        buffer = _floating_term.buf,
        callback = function()
          if _floating_term.win and vim.api.nvim_win_is_valid(_floating_term.win) then
            vim.api.nvim_win_close(_floating_term.win, true)
            _floating_term.win = nil
          end
        end,
      }
    )

    return nil
  end

  -- If we reach this point, the buffer already exists, so we just need to open the window.
  local opts = _terminal_window_opts()
  _floating_term.win = vim.api.nvim_open_win( _floating_term.buf, true, opts)
  vim.cmd.startinsert()

  return nil
end

--------------------------------------------------------------------------------------------
--                                    Public Functions                                    --
--------------------------------------------------------------------------------------------

function M.setup()
  -- Create the user command to toggle the floating terminal.
  vim.api.nvim_create_user_command("ToggleFloatingTerminal", _toggle_floating_terminal, {})

  -- Keymaps -------------------------------------------------------------------------------

  local function float_term_map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
  end

  float_term_map("n", "<F6>", _toggle_floating_terminal, "Toggle Float Terminal")
  float_term_map("t", "<F6>", _toggle_floating_terminal, "Toggle Float Terminal")
end

return M

-- vim:ts=2:sts=2:sw=2:et
