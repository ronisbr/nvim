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

-- Padding for the floating terminal: 1 row top/bottom, 4 columns left/right.
local ft_pad_v = 1
local ft_pad_h = 3

-- Local state of the floating terminal.
M.floating_term = {
  buf          = nil, -- .................................. Buffer for the floating terminal
  win          = nil, -- .................................. Window for the floating terminal
  jobid        = nil, -- ................................... Job ID for the terminal process
  backdrop_buf = nil, -- .................................... Buffer for the backdrop window
  backdrop_win = nil  -- ................................. Window for the backdrop (padding)
}

-- Local state of the bottom terminal.
M.bottom_term = {
  buf   = nil, -- ......................................... Buffer for the floating terminal
  win   = nil, -- ......................................... Window for the floating terminal
  jobid = nil  -- .......................................... Job ID for the terminal process
}

--------------------------------------------------------------------------------------------
--                                    Local Functions                                     --
--------------------------------------------------------------------------------------------

--- Update the FloatingTermBg highlight group based on the current Normal background.
-- Lightens the background for dark themes, darkens it for light themes.
local function update_floating_term_bg()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local bg = normal.bg

  if not bg then return end

  local r = bit.rshift(bit.band(bg, 0xFF0000), 16)
  local g = bit.rshift(bit.band(bg, 0x00FF00), 8)
  local b = bit.band(bg, 0x0000FF)

  -- Determine if the theme is light or dark based on perceived luminance.
  local luminance = 0.299 * r + 0.587 * g + 0.114 * b
  local offset = luminance < 128 and 15 or -10

  r = math.max(0, math.min(255, r + offset))
  g = math.max(0, math.min(255, g + offset))
  b = math.max(0, math.min(255, b + offset))

  vim.api.nvim_set_hl(0, "FloatingTermBg", { bg = string.format("#%02x%02x%02x", r, g, b) })
end

--- Return the window options for the floating terminal backdrop (outer) and terminal (inner).
-- @return table, table: Backdrop options and terminal options for nvim_open_win.
local function terminal_window_opts()
  -- Notice that we are removing two lines to take into account the status line and command
  -- line.
  local ui     = vim.api.nvim_list_uis()[1]
  local width  = math.floor(ui.width * 0.8)
  local height = math.floor((ui.height - 2) * 0.8)
  local col    = math.floor((ui.width - width) / 2)
  local row    = math.floor(((ui.height - 2) - height) / 2)

  local backdrop_opts = {
    border   = "none",
    col      = col,
    height   = height,
    relative = "editor",
    row      = row,
    style    = "minimal",
    width    = width,
    focusable = false,
    zindex   = 10,
  }

  local term_opts = {
    border   = "none",
    col      = col + ft_pad_h,
    height   = height - 2 * ft_pad_v,
    relative = "editor",
    row      = row + ft_pad_v,
    style    = "minimal",
    width    = width - 2 * ft_pad_h,
    zindex   = 11,
  }

  return backdrop_opts, term_opts
end

--- Open the backdrop window for the floating terminal.
local function open_backdrop(backdrop_opts)
  if not (
    M.floating_term.backdrop_buf and vim.api.nvim_buf_is_valid(M.floating_term.backdrop_buf)
  ) then
    M.floating_term.backdrop_buf = vim.api.nvim_create_buf(false, true)
  end

  M.floating_term.backdrop_win = vim.api.nvim_open_win(
    M.floating_term.backdrop_buf,
    false,
    backdrop_opts
  )
  vim.api.nvim_set_option_value(
    "winhl",
    "Normal:FloatingTermBg",
    { win = M.floating_term.backdrop_win }
  )
end

--- Close the backdrop window for the floating terminal.
local function close_backdrop()
  if (
    M.floating_term.backdrop_win and vim.api.nvim_win_is_valid(M.floating_term.backdrop_win)
  ) then
    vim.api.nvim_win_close(M.floating_term.backdrop_win, true)
    M.floating_term.backdrop_win = nil
  end
end

--- Toggle the floating terminal window.
-- If the terminal is open, it hides it. Otherwise, it creates or shows the floating
-- terminal. Handles buffer/window/job creation, keymaps, and autocmds for the terminal.
local function toggle_floating_terminal()
  if M.floating_term.win ~= nil and vim.api.nvim_win_is_valid(M.floating_term.win) then
    -- If the floating window is open, we hide it.
    vim.api.nvim_win_hide(M.floating_term.win)
    close_backdrop()
    return nil
  end

  -- Check if we need to create a new buffer for the terminal.
  if M.floating_term.buf == nil or not vim.api.nvim_buf_is_valid(M.floating_term.buf) then
    M.floating_term.buf = vim.api.nvim_create_buf(false, true)

    update_floating_term_bg()
    local backdrop_opts, term_opts = terminal_window_opts()

    -- Open the backdrop first, then the terminal on top.
    open_backdrop(backdrop_opts)

    M.floating_term.win = vim.api.nvim_open_win(
      M.floating_term.buf,
      true,
      term_opts
    )
    vim.api.nvim_set_option_value(
      "winhl",
      "Normal:FloatingTermBg",
      { win = M.floating_term.win }
    )

    M.floating_term.jobid = vim.fn.jobstart(
      vim.o.shell,
      {
        on_exit = function()
          M.floating_term.jobid = nil
          vim.schedule(
            function()
              if M.floating_term.win and vim.api.nvim_win_is_valid(M.floating_term.win) then
                vim.api.nvim_win_close(M.floating_term.win, true)
                M.floating_term.win = nil
              end
              close_backdrop()
            end
          )
        end,
        term = true
      }
    )

    vim.api.nvim_buf_call(
      M.floating_term.buf,
      function()
        vim.cmd.setfiletype("terminal")
      end
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

          -- Consume the next keypress that would be sent to the terminal.
          vim.schedule(
            function()
              vim.fn.getchar(0)
            end
          )

          return ""
        else
          esc_timer_ft:start(
            200,
            0,
            function()
              vim.schedule(
                function()
                  -- In the timeout, we send the `<Esc>` to the terminal.
                  vim.fn.chansend(M.floating_term.jobid, esc_key)
                end
              )
            end
          )
          return ""
        end
      end,
      {
        buffer  = M.floating_term.buf,
        expr    = true,
        noremap = true,
        silent  = true
      }
    )

    -- Autocmds ----------------------------------------------------------------------------

    local group_id = vim.api.nvim_create_augroup("FloatingTerminal", { clear = true } )

    -- Close the window and backdrop if the buffer is deleted.
    vim.api.nvim_create_autocmd(
      "BufWipeout",
      {
        buffer   = M.floating_term.buf,
        group    = group_id,
        callback = function()
          if M.floating_term.win and vim.api.nvim_win_is_valid(M.floating_term.win) then
            vim.api.nvim_win_close(M.floating_term.win, true)
            M.floating_term.win = nil
          end
          close_backdrop()
        end,
      }
    )

    -- Close the backdrop when the terminal window is closed (e.g., shell exits).
    vim.api.nvim_create_autocmd(
      "WinClosed",
      {
        group    = group_id,
        callback = function(args)
          if tonumber(args.match) == M.floating_term.win then
            M.floating_term.win = nil
            close_backdrop()
          end
        end,
      }
    )

    return nil
  end

  -- If we reach this point, the buffer already exists, so we just need to open the window.
  update_floating_term_bg()
  local backdrop_opts, term_opts = terminal_window_opts()
  open_backdrop(backdrop_opts)
  M.floating_term.win = vim.api.nvim_open_win(M.floating_term.buf, true, term_opts)
  vim.api.nvim_set_option_value(
    "winhl",
    "Normal:FloatingTermBg",
    { win = M.floating_term.win }
  )
  vim.cmd.startinsert()

  return nil
end

--- Toggle the bottom terminal window.
-- If the terminal is open, it hides it. Otherwise, it creates or shows the floating
-- terminal. Handles buffer/window/job creation, keymaps, and autocmds for the terminal.
local function toggle_bottom_terminal()
  if M.bottom_term.win ~= nil and vim.api.nvim_win_is_valid(M.bottom_term.win) then
    -- If the bottom window is open, we hide it.
    vim.api.nvim_win_hide(M.bottom_term.win)
    return nil
  end

  -- Check if we need to create a new buffer for the terminal.
  if M.bottom_term.buf and vim.api.nvim_buf_is_valid(M.bottom_term.buf) then
    vim.cmd("botright 15split")
    M.bottom_term.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(M.bottom_term.win, M.bottom_term.buf)
    vim.cmd.startinsert()
    return nil
  end

  -- If we reach this point, we need to open a new terminal.
  vim.cmd("botright 15split")
  M.bottom_term.win = vim.api.nvim_get_current_win()
  M.bottom_term.buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_win_set_buf(M.bottom_term.win, M.bottom_term.buf)

  M.bottom_term.jobid = vim.fn.jobstart(
    vim.o.shell,
    {
      on_exit = function() M.bottom_term.jobid = nil end,
      term = true
    }
  )

  vim.api.nvim_buf_call(
    M.bottom_term.buf,
    function() vim.cmd.setfiletype("terminal") end
  )

  vim.cmd.startinsert()

  -- Keymaps -------------------------------------------------------------------------------

  function bottom_term_map(lhs, rhs)
    vim.keymap.set(
      "t",
      lhs,
      rhs,
      {
        buffer  = M.bottom_term.buf,
        noremap = true,
        silent  = true
      }
    )
  end

  bottom_term_map("<C-w>h", "<C-\\><C-n><C-w>h")
  bottom_term_map("<C-w>j", "<C-\\><C-n><C-w>j")
  bottom_term_map("<C-w>k", "<C-\\><C-n><C-w>k")
  bottom_term_map("<C-w>l", "<C-\\><C-n><C-w>l")

  bottom_term_map("<C-w><Left>",  "<C-\\><C-n><C-w>h")
  bottom_term_map("<C-w><Down>",  "<C-\\><C-n><C-w>j")
  bottom_term_map("<C-w><Up>",    "<C-\\><C-n><C-w>k")
  bottom_term_map("<C-w><Right>", "<C-\\><C-n><C-w>l")

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

        -- Consume the next keypress that would be sent to the terminal.
        vim.schedule(function() vim.fn.getchar(0) end)

        return ""
      else
        esc_timer_bt:start(
          200,
          0,
          function()
            vim.schedule(
              function()
                -- In the timeout, we send the `<Esc>` to the terminal.
                vim.fn.chansend(M.bottom_term.jobid, esc_key)
              end
            )
          end
        )
        return ""
      end
    end,
    {
      buffer  = M.bottom_term.buf,
      expr    = true,
      noremap = true,
      silent  = true
    }
  )

  -- Autocmds ----------------------------------------------------------------------------

  local group_id = vim.api.nvim_create_augroup("BottomTerminal", { clear = true } )

  -- Close the window if the buffer is deleted.
  vim.api.nvim_create_autocmd(
    "BufWipeout",
    {
      buffer   = M.bottom_term.buf,
      group    = group_id,
      callback = function()
        if M.bottom_term.win and vim.api.nvim_win_is_valid(M.bottom_term.win) then
          vim.api.nvim_win_close(M.bottom_term.win, true)
          M.bottom_term.win = nil
        end
      end,
    }
  )

  -- Always start in insert mode when entering the terminal.
  vim.api.nvim_create_autocmd(
    "BufEnter",
    {
      buffer   = M.bottom_term.buf,
      group    = group_id,
      callback = function() vim.cmd.startinsert() end
    })

  -- Close Neovim if the bottom terminal is the only remaining window.
  vim.api.nvim_create_autocmd(
    "WinClosed",
    {
      group    = group_id,
      callback = function(args)
        -- Skip if the bottom terminal buffer isn’t defined or valid.
        if not (bottom_term and M.bottom_term.buf and vim.api.nvim_buf_is_valid(M.bottom_term.buf)) then
          return nil
        end

        -- ID of the window that is being closed (string -> number).
        local closing_win = tonumber(args.match)
        if not closing_win then return nil end

        -- List current windows and count how many will remain after this one closes.
        local wins = vim.api.nvim_list_wins()

        -- If after closing there will be exactly 1 window left.
        if #wins - 1 == 1 then
          -- Find that remaining window (the one that is not the closing window)
          local remaining_win = nil

          for _, w in ipairs(wins) do
            if w ~= closing_win then
              remaining_win = w
              break
            end
          end

          if not remaining_win or not vim.api.nvim_win_is_valid(remaining_win) then
            return nil
          end

          local remaining_buf = vim.api.nvim_win_get_buf(remaining_win)

          -- If the only remaining window would show the bottom terminal, quit Neovim.
          if remaining_buf == M.bottom_term.buf then
            -- Try graceful quit; if blocked (unsaved buffers), Neovim will prompt
            pcall(vim.cmd, "qa")
          end
        end
      end,
  })

  return nil
end

--- Sends the current buffer to the bottom terminal.
local function send_buffer_to_bottom_term()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local text  = table.concat(lines, "\n"):gsub("[\r\n]+$", "") .. "\n"
  M.send_to_bottom_term(text)
end

--- Sends the current buffer to the bottom terminal and focuses its window.
local function send_buffer_to_bottom_term_with_focus()
  send_buffer_to_bottom_term()
  if M.bottom_term.win and vim.api.nvim_win_is_valid(M.bottom_term.win) then
    vim.api.nvim_set_current_win(M.bottom_term.win)
  end
end

--- Sends the visually selected text to the bottom terminal.
local function send_visual_to_bottom_term()
  -- Get the start and end of the visual selection.
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  -- Figure out the active visual mode.
  local mode = vim.fn.mode()

  -- Use getregion to get selected lines as a table of strings.
  local lines = vim.fn.getregion(start_pos, end_pos, {type = mode})

  -- Concatenate the text to be sent to the terminal. We will remove all trailing newline
  -- characters.
  local text = table.concat(lines, "\n"):gsub("[\r\n]+$", "") .. "\n"

  M.send_to_bottom_term(text)
end

--- Sends the visually selected text to the bottom terminal and focuses its window.
local function send_visual_to_bottom_term_with_focus()
  send_visual_to_bottom_term()
  if M.bottom_term.win and vim.api.nvim_win_is_valid(M.bottom_term.win) then
    vim.api.nvim_set_current_win(M.bottom_term.win)
    vim.api.nvim_feedkeys(esc_key, "n", false)
  end
end

--------------------------------------------------------------------------------------------
--                                    Public Functions                                    --
--------------------------------------------------------------------------------------------

--- Setup the terminal plugin.
function M.setup()
  -- Create the user command to toggle the floating terminal.
  vim.api.nvim_create_user_command("ToggleFloatingTerminal", toggle_floating_terminal, {})
  vim.api.nvim_create_user_command("ToggleBottomTerminal",   toggle_bottom_terminal,   {})

  -- Keymaps -------------------------------------------------------------------------------

  local function term_map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
  end

  term_map("n", "<F5>",       toggle_floating_terminal,              "Toggle Float Terminal")
  term_map("t", "<F5>",       toggle_floating_terminal,              "Toggle Float Terminal")
  term_map("i", "<F5>",       "<Esc>:ToggleFloatingTerminal<CR>",    "Toogle Float Terminal")
  term_map("n", "<F6>",       toggle_bottom_terminal,                "Toggle Bottom Terminal")
  term_map("t", "<F6>",       toggle_bottom_terminal,                "Toggle Bottom Terminal")
  term_map("i", "<F6>",       "<Esc>:ToggleBottomTerminal<CR>",      "Toogle Bottom Terminal")
  term_map("n", "<Leader>bs", send_buffer_to_bottom_term,            "Send Buffer to Bottom Terminal")
  term_map("v", "<Leader>bs", send_visual_to_bottom_term,            "Send Selection to Bottom Terminal")
  term_map("n", "<Leader>bi", send_buffer_to_bottom_term_with_focus, "Send Buffer to Bottom Terminal with Focus")
  term_map("v", "<Leader>bi", send_visual_to_bottom_term_with_focus, "Send Selection to Bottom Terminal with Focus")
end

--- Send the given text to the bottom terminal.
---
--- @param text string: The text to send to the terminal.
function M.send_to_bottom_term(text)
  -- Ensure if the bottom terminal is running.
  if not (
    M.bottom_term and M.bottom_term.jobid and vim.fn.jobwait({ M.bottom_term.jobid }, 0)[1] == -1
  ) then
    vim.notify("Bottom terminal is not running.", vim.log.levels.ERROR)
    return nil
  end

  -- Send to terminal job.
  vim.fn.chansend(M.bottom_term.jobid, text)

  -- Update the terminal so that the cursor is at its end, if the window is valid.
  if vim.api.nvim_win_is_valid(M.bottom_term.win) then
    vim.api.nvim_win_set_cursor(
      M.bottom_term.win,
      { vim.api.nvim_buf_line_count(M.bottom_term.buf), 0 }
    )
  end
end

return M

