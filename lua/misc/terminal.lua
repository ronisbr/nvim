-- Description -----------------------------------------------------------------------------
--
-- Implement a floating terminal.
--
-- -----------------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------------------
--                                    Local Variables                                     --
--------------------------------------------------------------------------------------------

-- The `<Esc>` key sequence to send to the terminal.
local esc_key = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)

-- Timer to check if the `<Esc>` key is pressed twice quickly.
local esc_timer_ft = nil
local esc_timer_bt = nil

-- Local state of the floating terminal.
local floating_term = {
  buf   = nil, -- ......................................... Buffer for the floating terminal
  win   = nil, -- ......................................... Window for the floating terminal
  jobid = nil  -- .......................................... Job ID for the terminal process
}

-- Local state of the bottom terminal.
local bottom_term = {
  buf   = nil, -- ......................................... Buffer for the floating terminal
  win   = nil, -- ......................................... Window for the floating terminal
  jobid = nil  -- .......................................... Job ID for the terminal process
}

--------------------------------------------------------------------------------------------
--                                    Local Functions                                     --
--------------------------------------------------------------------------------------------

--- Return the window options for the floating terminal.
-- Calculates the size and position of the floating window based on the current UI size.
-- @return table: Window options for nvim_open_win.
local function terminal_window_opts()
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

--- Toggle the floating terminal window.
-- If the terminal is open, it hides it. Otherwise, it creates or shows the floating
-- terminal. Handles buffer/window/job creation, keymaps, and autocmds for the terminal.
local function toggle_floating_terminal()
  if floating_term.win ~= nil and vim.api.nvim_win_is_valid(floating_term.win) then
    -- If the floating window is open, we hide it.
    vim.api.nvim_win_hide(floating_term.win)
    return nil
  end

  -- Check if we need to create a new buffer for the terminal.
  if floating_term.buf == nil or not vim.api.nvim_buf_is_valid(floating_term.buf) then
    floating_term.buf = vim.api.nvim_create_buf(false, true)

    -- Create the window.
    floating_term.win = vim.api.nvim_open_win(
      floating_term.buf,
      true,
      terminal_window_opts()
    )

    floating_term.jobid = vim.fn.jobstart(
      vim.o.shell,
      {
        on_exit = function() floating_term.jobid = nil end,
        term = true
      }
    )
    vim.cmd.startinsert()

    -- Keymaps -----------------------------------------------------------------------------

    -- Pressing `<Esc>` once will send it to the terminal after 200 ms. If `<Esc>` is
    -- pressed twice in this window, we exit to normal mode.
    vim.keymap.set(
      "t",
      "<Esc>",
      function()
        esc_timer_ft = esc_timer_ft or vim.uv.new_timer()

        if esc_timer_ft:is_active() then
          esc_timer_ft:stop()
          vim.cmd.stopinsert()
          return ""
        else
          esc_timer_ft:start(
            200,
            0,
            function()
              vim.schedule(
                function()
                  -- In the timeout, we send the `<Esc>` to the terminal.
                  vim.fn.chansend(floating_term.jobid, esc_key)
                end
              )
            end
          )
          return ""
        end
      end,
      {
        expr    = true,
        noremap = true,
        silent  = true
      }
    )

    -- Autocmds ----------------------------------------------------------------------------

    -- Close the window if the buffer is deleted.
    vim.api.nvim_create_autocmd(
      "BufWipeout",
      {
        buffer = floating_term.buf,
        callback = function()
          if floating_term.win and vim.api.nvim_win_is_valid(floating_term.win) then
            vim.api.nvim_win_close(floating_term.win, true)
            floating_term.win = nil
          end
        end,
      }
    )

    return nil
  end

  -- If we reach this point, the buffer already exists, so we just need to open the window.
  local opts = terminal_window_opts()
  floating_term.win = vim.api.nvim_open_win(floating_term.buf, true, opts)
  vim.cmd.startinsert()

  return nil
end

--- Toggle the bottom terminal window.
-- If the terminal is open, it hides it. Otherwise, it creates or shows the floating
-- terminal. Handles buffer/window/job creation, keymaps, and autocmds for the terminal.
local function toggle_bottom_terminal()
  if bottom_term.win ~= nil and vim.api.nvim_win_is_valid(bottom_term.win) then
    -- If the bottom window is open, we hide it.
    vim.api.nvim_win_hide(bottom_term.win)
    return nil
  end

  -- Check if we need to create a new buffer for the terminal.
  if bottom_term.buf and vim.api.nvim_buf_is_valid(bottom_term.buf) then
    vim.cmd("botright 15split")
    bottom_term.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(bottom_term.win, bottom_term.buf)
    vim.cmd.startinsert()
    return nil
  end

  -- If we reach this point, we need to open a new terminal.
  vim.cmd("botright 15split")
  bottom_term.win = vim.api.nvim_get_current_win()
  bottom_term.buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_win_set_buf(bottom_term.win, bottom_term.buf)

  bottom_term.jobid = vim.fn.jobstart(
    vim.o.shell,
    {
      on_exit = function() bottom_term.jobid = nil end,
      term = true
    }
  )
  vim.cmd.startinsert()

  -- Keymaps -------------------------------------------------------------------------------

  vim.keymap.set('t', '<C-w>h', "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
  vim.keymap.set('t', '<C-w>j', "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
  vim.keymap.set('t', '<C-w>k', "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
  vim.keymap.set('t', '<C-w>l', "<C-\\><C-n><C-w>l", { noremap = true, silent = true })

  vim.keymap.set('t', '<C-w><Left>',  "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
  vim.keymap.set('t', '<C-w><Down>',  "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
  vim.keymap.set('t', '<C-w><Up>',    "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
  vim.keymap.set('t', '<C-w><Right>', "<C-\\><C-n><C-w>l", { noremap = true, silent = true })

  -- Pressing `<Esc>` once will send it to the terminal after 200 ms. If `<Esc>` is
  -- pressed twice in this window, we exit to normal mode.
  vim.keymap.set(
    "t",
    "<Esc>",
    function()
      esc_timer_bt = esc_timer_bt or vim.uv.new_timer()

      if esc_timer_bt:is_active() then
        esc_timer_bt:stop()
        vim.cmd.stopinsert()
        return ""
      else
        esc_timer_bt:start(
          200,
          0,
          function()
            vim.schedule(
              function()
                -- In the timeout, we send the `<Esc>` to the terminal.
                vim.fn.chansend(bottom_term.jobid, esc_key)
              end
            )
          end
        )
        return ""
      end
    end,
    {
      expr    = true,
      noremap = true,
      silent  = true
    }
  )

  -- Autocmds ----------------------------------------------------------------------------

  -- Close the window if the buffer is deleted.
  vim.api.nvim_create_autocmd(
    "BufWipeout",
    {
      buffer = bottom_term.buf,
      callback = function()
        if bottom_term.win and vim.api.nvim_win_is_valid(bottom_term.win) then
          vim.api.nvim_win_close(bottom_term.win, true)
          bottom_term.win = nil
        end
      end,
    }
  )

  vim.api.nvim_create_autocmd(
    "BufEnter",
    {
      buffer = bottom_term.buf,
      callback = function() vim.cmd.startinsert() end
  })

  return nil
end

local function send_to_bottom_term(text)
  -- Ensure if the bottom terminal is running.
  if not (
    bottom_term and bottom_term.jobid and vim.fn.jobwait({ bottom_term.jobid }, 0)[0] == -1
  ) then
    vim.notify("Bottom terminal is not running.", vim.log.levels.ERROR)
    return nil
  end

  -- Send to terminal job.
  vim.fn.chansend(bottom_term.jobid, text)
end

local function send_visual_to_bottom_term()
  -- Detect selection mode: 'v' = charwise, 'V' = linewise, CTRL-V = blockwise
  local mode = vim.fn.visualmode()

  -- Get start and end positions (line, col)
  local start_pos = vim.fn.getpos("v")
  local end_pos   = vim.fn.getpos(".")

  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col     = end_pos[2],   end_pos[3]

  -- Normalize positions if selection is backwards
  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col   = end_col, start_col
  end

  -- Get all selected lines
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if mode == "v" then
    -- Characterwise: trim first and last lines to column boundaries
    if #lines == 1 then
      lines[1] = string.sub(lines[1], start_col, end_col)
    else
      lines[1]   = string.sub(lines[1], start_col)
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end
  elseif mode == "\22" then
    -- Blockwise (<C-v>): extract only the block range
    for i, line in ipairs(lines) do
      lines[i] = string.sub(line, start_col, end_col)
    end
  elseif mode == "V" then
    -- Linewise: keep full lines as-is (no column trimming)
    -- nothing to trim
  end

  -- Add newline so the terminal executes immediately
  local text = table.concat(lines, "\n") .. "\n"

  send_to_bottom_term(text)
end

-- Map it in isual mode
vim.keymap.set("v", "<leader>s", send_visual_to_bottom_term, { desc = "Send selection to bottom terminal" })

--------------------------------------------------------------------------------------------
--                                    Public Functions                                    --
--------------------------------------------------------------------------------------------

--- Setup the floating terminal plugin.
-- Create the user command and keymaps for toggling the floating terminal.
function M.setup()
  -- Create the user command to toggle the floating terminal.
  vim.api.nvim_create_user_command("ToggleFloatingTerminal", toggle_floating_terminal, {})

  -- Keymaps -------------------------------------------------------------------------------

  local function float_term_map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
  end

  float_term_map("n", "<F5>", toggle_floating_terminal, "Toggle Float Terminal")
  float_term_map("t", "<F5>", toggle_floating_terminal, "Toggle Float Terminal")
  float_term_map("n", "<F6>", toggle_bottom_terminal, "Toggle Float Terminal")
  float_term_map("t", "<F6>", toggle_bottom_terminal, "Toggle Float Terminal")
end

return M

-- vim:ts=2:sts=2:sw=2:et
