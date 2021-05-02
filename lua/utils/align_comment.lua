local M = {}

local utf8 = require('utf8'):init()
local utf8_aux = require('utils.utf8_aux')
local wcwidth = require('wcwidth.init')

-- Map the convert the file type with the inline comment pattern.
local mode_map = {
  ['julia'] = '#',
  ['lua'] = '%-%-'
}

-- Align the comments in the lines considering the alignment `alignemnt`. It can
-- be `l` for left, `c` for center, and `r` for right. The filling char will be
-- requested from the user.
function M.align_comments(alignment)
  -- Ask the user whick fill char they want.
  local answer = vim.call('input', 'Fill char [ ]: ')

  if (string.len(answer) == 0) then
    answer = ' '
  end

  -- Make sure only one character is obtained.
  local fill_char = utf8.sub(answer, 1, 1)

  -- Align the comments.
  M.align_comments_with_char(fill_char, alignment)
end

-- Align the comments in the lines considering the alignment `alignemnt` and the
-- filling char `fill_char`. The `alignment` argument can be `l` for left, `c`
-- for center, and `r` for right.
function M.align_comments_with_char(fill_char, alignment)
  -- Get the comment pattern using the current file type.
  local filetype = vim.bo.filetype
  local comment_pattern = mode_map[filetype]

  if (comment_pattern ~= nil) then
    M._align_comments(comment_pattern, fill_char, alignment)
  end
end

-- -----------------------------------------------------------------------------
--                             Private functions
-- -----------------------------------------------------------------------------

function M._align_comments(comment_pattern, fill_char, alignment)
  -- Check in which mode we are.
  local mode = 'v'

  -- Get the buffer of the current window.
  local buf = vim.api.nvim_win_get_buf(0)

  if (mode == 'n') then
    -- In normal mode, we just need to get the current cursor line.
    local cur_pos = vim.api.nvim_win_get_cursor(0)

    -- Get the line of the cursor.
    local line = vim.api.nvim_buf_get_lines(buf, cur_pos[1]-1, cur_pos[1], true)

    -- Align the comment in the line.
    local new_line = M._align_comment_in_line(line[1],
                                              comment_pattern,
                                              fill_char,
                                              alignment)

    -- Write the line in the buffer.
    vim.api.nvim_buf_set_lines(buf, cur_pos[1]-1, cur_pos[1], true, {new_line})

  elseif ((mode == 'v') or (mode == 'V') or (mode == '')) then
    -- In visual modes, we need to take a set of lines.
    local line_start = vim.fn.getpos('v')[2]
    local line_end = vim.fn.getcurpos()[2]

    -- The selection can be up instead of down.
    if (line_start > line_end) then
      local aux = line_start
      line_start = line_end
      line_end = aux
    end

    for l = line_start,line_end do
      -- Get and align the l-th line.
      local line = vim.api.nvim_buf_get_lines(buf, l-1, l, true)

      -- Align the comment in the line.
      local new_line = M._align_comment_in_line(line[1],
                                                comment_pattern,
                                                fill_char,
                                                alignment)

      -- Write the line in the buffer.
      vim.api.nvim_buf_set_lines(buf, l-1, l, true, {new_line})
    end
  end
end

-- Given the comment pattern `comment_pattern`, align the comment in the line
-- `line` with the fill character `fill_char`. The alignment is selected by
-- `alignment`, which can be 'l' (left), 'c' (center), or 'r' (right).
function M._align_comment_in_line(line, comment_pattern, fill_char, alignment)
  -- Search for a comment in this line.
  local cstart, cend = string.find(line, comment_pattern)

  if ((cstart ~= nil) and (cend ~= nil)) then
    local char_id = utf8_aux.get_char_index_at_bytepos(line, cend)

    -- Get the string between the beginning of the line and the comment.
    local code = utf8.sub(line, 1, char_id)

    -- Get the string after the comment until the end of the line.
    local comment = utf8.sub(line, char_id + 1, -1)

    -- Remove the leading and trailing space in the comment.
      comment = string.gsub(comment, '^%s*(.-)%s*$', '%1')

    -- Count how many characters we have.
    local total_chars = utf8_aux.display_len(code) + utf8_aux.display_len(comment)

    -- Get the size of text width.
    local textwidth = vim.o.textwidth

    -- Check how many characters we must add.
    local rem = textwidth - total_chars

    if (alignment == 'l') then
      if rem >= 2 then
        output = code .. ' ' .. comment .. ' ' .. string.rep(fill_char, rem)
      else
        output = code .. ' ' .. comment
      end

    elseif (alignment == 'c') then
      if rem >= 3 then
        rem = rem - 3
        rem_o2 = math.floor(rem / 2)
        fill_beg = string.rep(fill_char, rem_o2)
        fill_end = string.rep(fill_char, rem - rem_o2)
        output = code .. ' ' .. fill_beg .. ' ' .. comment .. ' ' .. fill_end
      else
        output = code .. ' ' .. comment
      end

    else
      if rem >= 2 then
        rem = rem - 2
        output = code .. ' ' .. string.rep(fill_char, rem) .. ' ' .. comment
      else
        output = code .. ' ' .. comment
      end
    end

    -- Trim any trailing space.
    output = string.gsub(output, '%s*$', '')

    return output
  else
    return line
  end
end

return M
