-- Description -----------------------------------------------------------------------------
--
-- Functions to help text manipulation.
--
-- -----------------------------------------------------------------------------------------

local M = {}

local utf8 = require('utf8.utf8')
local utf8_misc = require('misc.utf8')
local wcwidth = require('wcwidth.init')

--- Fill the current line with `pattern` until the break column.
--
-- pattern String with the pattern to fill the line.
function M.fill_with_pattern(pattern)
  -- Get the buffer of the current window.
  local buf = vim.api.nvim_win_get_buf(0)

  -- Get the cursor position.
  local cur_pos = vim.api.nvim_win_get_cursor(0)

  -- Get the line text.
  local line = vim.api.nvim_buf_get_lines(buf, cur_pos[1] - 1, cur_pos[1], true)

  -- Get the length of the repeating pattern.
  local pattern_len = utf8_misc.display_len(pattern)

  -- Get the size of text width.
  local textwidth = vim.o.textwidth

  -- If text width is 0, we should not fill the line.
  if textwidth == 0 then
    return
  end

  -- Get the string from the beginning of the line up to the cursor position.
  local prefix = utf8.char(utf8.codepoint(line[1], 1, cur_pos[2] + 1))

  -- Get the display size of the prefix.
  local prefix_len = utf8_misc.display_len(prefix)

  -- Count how many character we must add from the cursor position until the break column.
  local num_rep = math.floor((textwidth - prefix_len) / pattern_len)

  -- If the number of repetitions is equal or less than 0, it means that we have no space
  -- between the cursor and the column defined by `textwidth`. In this case, we should do
  -- nothing.
  if num_rep >= 0 then
    local output = prefix .. string.rep(pattern, num_rep)

    -- Complete the fill with part of the pattern.
    local rem = (textwidth - prefix_len) - (num_rep * pattern_len)

    if rem > 0 then
      local inc = 0

      for _, c in utf8.codes(pattern) do
        local w = wcwidth(utf8.codepoint(c))

        if w < 0 then break end
        inc = inc + w

        if inc > rem then break end
        output = output .. c
      end
    end

    -- Write the line in the buffer.
    vim.api.nvim_buf_set_lines(buf, cur_pos[1] - 1, cur_pos[1], true, { output })
  end
end

--- Fill the current line with the cursor character until the break column.
function M.fill_with_cursor_character()
  -- Get the buffer of the current window.
  local buf = vim.api.nvim_win_get_buf(0)

  -- Get the cursor position.
  local cur_pos = vim.api.nvim_win_get_cursor(0)

  -- Get the line text.
  local line = vim.api.nvim_buf_get_lines(buf, cur_pos[1] - 1, cur_pos[1], true)

  -- Get the character under the cursor.
  local char = utf8.char(utf8.codepoint(line[1], cur_pos[2] + 1))

  return M.fill_with_pattern(char)
end

--- Fill the current line with user's input until the break column.
function M.fill_with_input()
  -- Get the input pattern.
  local pattern = vim.fn.input("Fill pattern: ")

  return M.fill_with_pattern(pattern)
end

return M
