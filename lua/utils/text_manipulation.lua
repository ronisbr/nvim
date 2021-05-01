local M = {}

local utf8 = require('utf8'):init()
local utf8_aux = require('utils.utf8_aux')
local wcwidth = require('wcwidth.init')

-- Fill the current line between the cursor position and the `textwidth` column
-- with the character on the cursor.
function M.fill_with_pattern(pattern)
  -- Get the buffer of the current window.
  local buf = vim.api.nvim_win_get_buf(0)

  -- Get the cursor position.
  local cur_pos = vim.api.nvim_win_get_cursor(0)

  -- Get the line text.
  local line = vim.api.nvim_buf_get_lines(buf, cur_pos[1]-1, cur_pos[1], true)

  -- Get the length of the repeating pattern.
  local pattern_len = utf8_aux.display_len(pattern)

  -- Get the size of text width.
  local textwidth = vim.o.textwidth

  -- Get the character index at the cursor position.
  local char_id = utf8_aux.get_char_index_at_bytepos(line[1], cur_pos[2] + 1)

  -- Get the display size of the line in the selected character.
  local subline_dlen = utf8_aux.display_len(utf8.sub(line[1], 1, char_id))

  -- Count how many character we must add from the cursor position until the
  -- break column.
  local num_rep = math.floor((textwidth - subline_dlen)/pattern_len)

  -- If the number of repetitions is equal or less than 0, then it means that we
  -- have no space between the cursor and the column defined by `textwidth`. In
  -- this case, we should do nothing.
  if num_rep >= 0 then
    local output = utf8.sub(line[1], 1, char_id) .. string.rep(pattern, num_rep)

    -- Complete the fill with part of the pattern.
    local rem = (textwidth - subline_dlen) - (num_rep * pattern_len)

    if rem > 0 then
      local inc = 0

      for _, rune in utf8.codes(pattern) do
        local w = wcwidth(rune)
        if w < 0 then break end
        inc = inc + w
        if inc > rem then break end
        output = output .. utf8.char(rune)
      end
    end

    -- Write the line in the buffer.
    vim.api.nvim_buf_set_lines(buf, cur_pos[1]-1, cur_pos[1], true, {output})
  end
end

-- Fill the current line between the cursor position and the `textwidth` column
-- with the character on the cursor.
function M.fill_with_cursor_character()
  -- Get the buffer of the current window.
  local buf = vim.api.nvim_win_get_buf(0)

  -- Get the cursor position.
  local cur_pos = vim.api.nvim_win_get_cursor(0)

  -- Get the line text.
  local line = vim.api.nvim_buf_get_lines(buf, cur_pos[1]-1, cur_pos[1], true)

  -- Get the character under the cursor.
  local char = utf8_aux.get_char_at_bytepos(line[1], cur_pos[2]+1)

  return M.fill_with_pattern(char)
end

-- Fill the current line between the cursor position and the `textwidth` column
-- with a pattern obtained from the user's input.
function M.fill_with_input()
  -- Get the buffer of the current window.
  local buf = vim.api.nvim_win_get_buf(0)

  -- Get the cursor position.
  local cur_pos = vim.api.nvim_win_get_cursor(0)

  -- Get the line text.
  local line = vim.api.nvim_buf_get_lines(buf, cur_pos[1]-1, cur_pos[1], true)

  -- Get the input pattern.
  local pattern = vim.call('input', 'Fill pattern: ')

  return M.fill_with_pattern(pattern)
end

return M
