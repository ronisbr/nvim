-- Description -----------------------------------------------------------------------------
--
-- Functions to manipulate comments.
--
-- -----------------------------------------------------------------------------------------

local M = {}

-- Map the convert the file type with the inline comment pattern.
local mode_map = {
  ['julia'] = '#',
  ['lua'] = '%-%-'
}

--- Align the comments in the lines considering the alignment `alignemnt`.
--
-- `alignment` can be `"l"` for left, `"c"` for center, and `"r"` for right. The filling
-- character will be requested to the user.
function M.align_comments(alignment)
  -- Ask the user which fill char they want.
  local answer = vim.fn.input("Fill char [ ]: ")

  if (string.len(answer) == 0) then
    answer = " "
  end

  -- Make sure only one character is obtained.
  local fill_char = vim.fn.strcharpart(answer, 0, 1)

  -- Align the comments.
  M.align_comments_with_char(fill_char, alignment)
end

--- Align the comments in the lines with `fill_char` considering the `alignemnt`.
--
-- The `alignment` argument can be `"l"` for left, `"c"` for center, and `"r"` for right.
function M.align_comments_with_char(fill_char, alignment)
  -- Get the comment pattern using the current file type.
  local filetype = vim.bo.filetype
  local comment_pattern = mode_map[filetype]

  if (comment_pattern ~= nil) then
    M._align_comments(comment_pattern, fill_char, alignment)
  end
end

-- Private Functions -----------------------------------------------------------------------

--- Align the comments in the buffer lines.
function M._align_comments(comment_pattern, fill_char, alignment)
  -- Check in which mode we are.
  local mode = vim.api.nvim_get_mode().mode

  -- Get the buffer of the current window.
  local buf = vim.api.nvim_win_get_buf(0)

  if (mode == "n") then
    -- In normal mode, we just need to get the current cursor line.
    local cur_pos = vim.api.nvim_win_get_cursor(0)

    -- Get the line of the cursor.
    local line = vim.api.nvim_buf_get_lines(buf, cur_pos[1] - 1, cur_pos[1], true)

    -- Align the comment in the line.
    local new_line = M._align_comment_in_line(
      line[1],
      comment_pattern,
      fill_char,
      alignment
    )

    -- Write the line in the buffer.
    vim.api.nvim_buf_set_lines(buf, cur_pos[1] - 1, cur_pos[1], true, { new_line })

  elseif ((mode == 'v') or (mode == 'V') or (mode == '')) then
    -- In visual modes, we need to take a set of lines.
    local line_start = vim.fn.getpos('v')[2]
    local line_end = vim.fn.getcurpos()[2]

    -- The selection can be up instead of down.
    if (line_start > line_end) then
      local aux = line_start
      line_start = line_end
      line_end = aux
    end

    for l = line_start, line_end do
      -- Get and align the l-th line.
      local line = vim.api.nvim_buf_get_lines(buf, l - 1, l, true)

      -- Align the comment in the line.
      local new_line = M._align_comment_in_line(
        line[1],
        comment_pattern,
        fill_char,
        alignment
      )

      -- Write the line in the buffer.
      vim.api.nvim_buf_set_lines(buf, l - 1, l, true, { new_line })
    end
  end
end

--- Align the comment in `line`.
--
-- Given the `comment_pattern`, align the comment in the `line` with the fill character
-- `fill_char`. The alignment is selected by `alignment`, which can be `"l"` (left), `"c"`
-- (center), or `"r"` (right).
function M._align_comment_in_line(line, comment_pattern, fill_char, alignment)
  -- Search for a comment in this line.
  local cstart, cend = string.find(line, comment_pattern)

  if ((cstart ~= nil) and (cend ~= nil)) then
    local char_id

    char_id, _ = vim.str_utfindex(line, cend)

    if char_id == nil then
      return line
    end

    -- Get the string between the beginning of the line and the comment.
    local code = vim.fn.strcharpart(line, 0, char_id)

    -- Get the string after the comment until the end of the line.
    local comment = vim.fn.strcharpart(line, char_id)

    -- Remove the leading and trailing space in the comment.
    comment = string.gsub(comment, "^%s*(.-)%s*$", "%1")

    -- Count how many characters we have.
    local total_chars = vim.fn.strdisplaywidth(code) + vim.fn.strdisplaywidth(comment)

    -- Get the size of text width.
    local tw = vim.o.textwidth

    -- Check how many characters we must add.
    local rem = tw - total_chars

    -- Variable to store the line with the aligned comment.
    local output

    if (alignment == "l") then

      if rem >= 2 then
        output = code .. " " .. comment .. " " .. string.rep(fill_char, rem)
      else
        output = code .. " " .. comment
      end

    elseif (alignment == "c") then
      if rem >= 3 then
        rem = rem - 3
        local lpad = math.floor(rem / 2)
        local rpad = rem - lpad

        local lstr = string.rep(fill_char, lpad)
        local rstr = string.rep(fill_char, rpad)

        output = code .. " " .. lstr .. " " .. comment .. " " .. rstr
      else
        output = code .. " " .. comment
      end

    else
      if rem >= 2 then
        rem = rem - 2
        output = code .. " " .. string.rep(fill_char, rem) .. " " .. comment
      else
        output = code .. " " .. comment
      end
    end

    -- Trim any trailing space.
    output = string.gsub(output, "%s*$", "")

    return output

  else
    return line
  end
end

return M

