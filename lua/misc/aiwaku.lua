-- Description -----------------------------------------------------------------------------
--
-- Utility functions for aiwaku.nvim.
--
-- -----------------------------------------------------------------------------------------

local M = {}

--- Prompt the user for input and send it to the active aiwaku session terminal.
---
--- If `ls` and `le` are provided, the file reference appended to the prompt will be a line
--- range (`filepath:ls-le`). Otherwise, the reference will be the current cursor line
--- (`filepath:line`). The final string sent to the terminal has the form
--- `[input] filepath:ref\n`.
---
---@param ls number|nil Start line of the visual selection (1-indexed).
---@param le number|nil End line of the visual selection (1-indexed).
function M.prompt_and_send(ls, le)
  local filepath = vim.api.nvim_buf_get_name(0)

  if filepath == "" then
    vim.notify("[aiwaku] Buffer has no file name", vim.log.levels.WARN)
    return
  end

  local ref

  if ls and le then
    if ls > le then
      ls, le = le, ls
    end

    ref = filepath .. ":" .. ls .. "-" .. le
  else
    ref = filepath .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
  end

  local state   = require("aiwaku.state")
  local session = require("aiwaku.session")
  local window  = require("aiwaku.window")

  -- Padding for the prompt floating window.
  local pad_v = 1
  local pad_h = 3

  -- Create the prompt buffer.
  local prompt_buf = vim.api.nvim_create_buf(false, true)

  -- Enable markdown syntax highlighting for the prompt buffer.
  vim.bo[prompt_buf].filetype  = "markdown"

  -- Wipe the buffer when hidden to avoid orphaned buffers.
  vim.bo[prompt_buf].bufhidden = "wipe"

  -- Use "acwrite" so `:w` triggers `BufWriteCmd` instead of writing to disk, allowing us to
  -- intercept and send the prompt to the AI backend.
  vim.bo[prompt_buf].buftype   = "acwrite"

  vim.api.nvim_buf_set_name(prompt_buf, "aiwaku-prompt")

  -- Ensure the FloatingTermBg highlight is set based on the current Normal background.
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local bg     = normal.bg

  if bg then
    local r = bit.rshift(bit.band(bg, 0xFF0000), 16)
    local g = bit.rshift(bit.band(bg, 0x00FF00), 8)
    local b = bit.band(bg, 0x0000FF)

    local luminance = 0.299 * r + 0.587 * g + 0.114 * b
    local offset    = luminance >= 128 and -7 or 15

    r = math.max(0, math.min(255, r + (luminance >= 128 and -4 or offset)))
    g = math.max(0, math.min(255, g + offset))
    b = math.max(0, math.min(255, b + (luminance >= 128 and -10 or offset)))

    vim.api.nvim_set_hl(
      0,
      "FloatingTermBg",
      { bg = string.format("#%02x%02x%02x", r, g, b) }
    )
  end

  -- Compute the floating window dimensions (backdrop includes padding).
  local ui     = vim.api.nvim_list_uis()[1]
  local tw     = vim.bo.textwidth > 0 and vim.bo.textwidth or vim.go.textwidth
  local width  = tw + 13
  local height = math.floor(ui.height * 0.4)
  local row    = math.floor((ui.height - height) / 2)
  local col    = math.floor((ui.width - width) / 2)

  -- Open the backdrop window (dimmed background).
  local backdrop_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[backdrop_buf].bufhidden = "wipe"

  local backdrop_win = vim.api.nvim_open_win(
    backdrop_buf,
    false,
    {
      relative  = "editor",
      width     = width,
      height    = height,
      row       = row,
      col       = col,
      style     = "minimal",
      border    = "none",
      focusable = false,
      zindex    = 10,
    }
  )

  vim.wo[backdrop_win].winhl = "Normal:FloatingTermBg"

  -- Create the title bar at the top of the backdrop.
  local tool          = state.current_tool or (state.config and state.config.cmd[1])
  local model_name    = tool and tool.name or "Unknown"
  local title_text    = "Aiwaku Prompt [" .. model_name .. "]"
  local title_padding = math.floor((width - #title_text) / 2)

  if title_padding < 0 then
    title_padding = 0
  end

  local title_line = string.rep(" ", title_padding) .. title_text
  local title_buf  = vim.api.nvim_create_buf(false, true)

  vim.bo[title_buf].bufhidden = "wipe"

  vim.api.nvim_buf_set_lines(title_buf, 0, -1, false, { title_line })

  local title_win = vim.api.nvim_open_win(
    title_buf,
    false,
    {
      relative  = "editor",
      width     = width,
      height    = 1,
      row       = row + pad_v,
      col       = col,
      style     = "minimal",
      border    = "none",
      focusable = false,
      zindex    = 11,
    }
  )

  vim.wo[title_win].winhl = "Normal:FloatingTermBg"

  local ns = vim.api.nvim_create_namespace("aiwaku_prompt")
  vim.api.nvim_buf_set_extmark(
    title_buf,
    ns,
    0,
    0,
    { line_hl_group = "Title" }
  )

  -- Create a horizontal separator between title and prompt.
  local sep_line    = string.rep("─", width)
  local sep_top_buf = vim.api.nvim_create_buf(false, true)

  vim.bo[sep_top_buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(sep_top_buf, 0, -1, false, { sep_line })

  local sep_top_win = vim.api.nvim_open_win(
    sep_top_buf,
    false,
    {
      relative  = "editor",
      width     = width,
      height    = 1,
      row       = row + pad_v + 1,
      col       = col,
      style     = "minimal",
      border    = "none",
      focusable = false,
      zindex    = 11,
    }
  )

  vim.wo[sep_top_win].winhl = "Normal:FloatingTermBg"
  vim.api.nvim_buf_set_extmark(
    sep_top_buf,
    ns,
    0,
    0,
    { line_hl_group = "NonText" }
  )

  -- Open the prompt window inside the backdrop with padding.
  -- Reserve 1 row for the title, 1 separator, 1 separator, 1 row for the hint bar.
  local inner_width  = width  - 2 * pad_h
  local inner_height = height - 2 * pad_v - 4
  local inner_row    = row + pad_v + 2
  local inner_col    = col + pad_h

  local prompt_win = vim.api.nvim_open_win(
    prompt_buf,
    true,
    {
      relative = "editor",
      width    = inner_width,
      height   = inner_height,
      row      = inner_row,
      col      = inner_col,
      border   = "none",
      zindex   = 11,
    }
  )

  -- Set up the prompt window: show line numbers but disable all other chrome.
  vim.wo[prompt_win].colorcolumn    = ""
  vim.wo[prompt_win].cursorline     = false
  vim.wo[prompt_win].fillchars      = "eob: "
  vim.wo[prompt_win].foldcolumn     = "0"
  vim.wo[prompt_win].list           = false
  vim.wo[prompt_win].number         = true
  vim.wo[prompt_win].relativenumber = false
  vim.wo[prompt_win].signcolumn     = "no"
  vim.wo[prompt_win].spell          = false
  vim.wo[prompt_win].statusline     = " "
  vim.wo[prompt_win].winbar         = ""
  vim.wo[prompt_win].winhl          = "Normal:FloatingTermBg,LineNr:FloatingTermBg"

  -- Create a horizontal separator between prompt and hint bar.
  local sep_bot_buf = vim.api.nvim_create_buf(false, true)

  vim.bo[sep_bot_buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(sep_bot_buf, 0, -1, false, { sep_line })

  local sep_bot_win = vim.api.nvim_open_win(
    sep_bot_buf,
    false,
    {
      border    = "none",
      col       = col,
      focusable = false,
      height    = 1,
      relative  = "editor",
      row       = row + height - 3,
      style     = "minimal",
      width     = width,
      zindex    = 11,
    }
  )

  vim.wo[sep_bot_win].winhl = "Normal:FloatingTermBg"
  vim.api.nvim_buf_set_extmark(
    sep_bot_buf,
    ns,
    0,
    0,
    { line_hl_group = "NonText" }
  )

  -- Create the hint bar at the bottom of the backdrop.
  local hint_buf = vim.api.nvim_create_buf(false, true)

  vim.bo[hint_buf].bufhidden = "wipe"

  local hint_text    = ":w => Send Prompt | q => Quit"
  local hint_padding = math.floor((width - #hint_text) / 2)

  if hint_padding < 0 then
    hint_padding = 0
  end

  local hint_line = string.rep(" ", hint_padding) .. hint_text

  vim.api.nvim_buf_set_lines(hint_buf, 0, -1, false, { hint_line })

  local hint_win = vim.api.nvim_open_win(
    hint_buf,
    false,
    {
      border    = "none",
      col       = col,
      focusable = false,
      height    = 1,
      relative  = "editor",
      row       = row + height - 2,
      style     = "minimal",
      width     = width,
      zindex    = 11,
    }
  )

  vim.wo[hint_win].winhl = "Normal:FloatingTermBg"
  vim.api.nvim_buf_set_extmark(
    hint_buf,
    ns,
    0,
    0,
    { line_hl_group = "Comment" }
  )

  -- Helper: close all floating windows.
  local closed = false

  local function close_wins()
    if closed then
      return
    end

    closed = true

    for _, w in ipairs({ prompt_win, title_win, sep_top_win, sep_bot_win, hint_win, backdrop_win }) do
      if vim.api.nvim_win_is_valid(w) then
        vim.api.nvim_win_close(w, true)
      end
    end
  end

  -- Helper: send prompt content to aiwaku.
  local function send_prompt()
    local lines = vim.api.nvim_buf_get_lines(prompt_buf, 0, -1, false)
    local input = vim.fn.join(lines, "\n")

    input = input:gsub("^%s+", ""):gsub("%s+$", "")
    close_wins()

    local function send(current_session, session_name)
      if not window.win_visible(state.win_id) then
        session.open_session(current_session)
      end

      -- Disable visual noise in the aiwaku sidebar terminal.
      local sid_win = state.win_id

      if sid_win and vim.api.nvim_win_is_valid(sid_win) then
        local sid_buf = vim.api.nvim_win_get_buf(sid_win)

        vim.b[sid_buf].miniindentscope_disable = true
        vim.b[sid_buf].minitrailspace_disable  = true
        vim.wo[sid_win].list                   = false
      end

      local bufnr = state.session_bufnrs[session_name]

      if not bufnr then
        vim.notify("[aiwaku] Session buffer not found", vim.log.levels.WARN)
        return
      end

      local job_id = vim.b[bufnr].terminal_job_id

      if not job_id then
        vim.notify("[aiwaku] Sidebar terminal has no job channel", vim.log.levels.WARN)
        return
      end

      local content = (input ~= "" and (input .. " ") or "") .. ref .. "\n"

      vim.api.nvim_chan_send(job_id, content)
      vim.api.nvim_set_current_win(state.win_id)
      vim.cmd("startinsert")
    end

    local session_name    = state.current_session
    local current_session = session_name and session.find_session(session_name)

    if not current_session then
      session.new_session()

      local attempts     = 0
      local max_attempts = 20
      local interval_ms  = 50

      local function try_send()
        attempts        = attempts + 1
        session_name    = state.current_session
        current_session = session_name and session.find_session(session_name)

        if current_session then
          send(current_session, session_name)
        elseif attempts < max_attempts then
          vim.defer_fn(try_send, interval_ms)
        else
          vim.notify("[aiwaku] Failed to initialize session", vim.log.levels.ERROR)
        end
      end

      vim.defer_fn(try_send, interval_ms)

      return
    end

    send(current_session, session_name)
  end

  -- Keymaps for the prompt buffer.
  vim.keymap.set("n", "q",     close_wins, { buffer = prompt_buf, nowait = true })
  vim.keymap.set("n", "<Esc>", close_wins, { buffer = prompt_buf, nowait = true })

  vim.api.nvim_create_autocmd(
    "BufWriteCmd",
    {
      buffer = prompt_buf,
      callback = function()
        send_prompt()
      end,
    }
  )

  -- Close hint window when the prompt window is closed by other means.
  vim.api.nvim_create_autocmd(
    "WinClosed",
    {
      pattern  = tostring(prompt_win),
      once     = true,
      callback = close_wins,
    }
  )

  -- Start in insert mode.
  vim.cmd("startinsert")
end

return M
