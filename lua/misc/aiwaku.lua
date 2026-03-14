-- Description -----------------------------------------------------------------------------
--
-- Utility functions for aiwaku.nvim.
--
-- -----------------------------------------------------------------------------------------

local M = {}

--- Prompt the user for input and send it to the active aiwaku session terminal.
--
-- If `ls` and `le` are provided, the file reference appended to the prompt will be a line
-- range (`filepath:ls-le`). Otherwise, the reference will be the current cursor line
-- (`filepath:line`). The final string sent to the terminal has the form
-- `[input] filepath:ref\n`.
--
--- @param ls number|nil Start line of the visual selection (1-indexed).
--- @param le number|nil End line of the visual selection (1-indexed).
function M.prompt_and_send(ls, le)
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    vim.notify("[aiwaku] Buffer has no file name", vim.log.levels.WARN)
    return
  end

  local ref
  if ls and le then
    if ls > le then ls, le = le, ls end
    ref = filepath .. ":" .. ls .. "-" .. le
  else
    ref = filepath .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
  end

  vim.ui.input({ prompt = "Prompt: " }, function(input)
    if not input then return end

    local state   = require("aiwaku.state")
    local session = require("aiwaku.session")
    local window  = require("aiwaku.window")

    local function send(current_session, session_name)
      if not window.win_visible(state.win_id) then
        session.open_session(current_session)
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
    end

    local session_name    = state.current_session
    local current_session = session_name and session.find_session(session_name)

    if not current_session then
      session.new_session()

      local attempts     = 0
      local max_attempts = 20
      local interval_ms  = 50

      local function try_send()
        attempts = attempts + 1
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
  end)
end

return M
