local M = {}

local utf8 = require('utf8'):init()
local wcwidth = require('wcwidth.init')

function M.display_len(str)
  local dlen = 0

  for _, rune in utf8.codes(str) do
    local w = wcwidth(rune)

    if w < 0 then
      return -1
    end

    dlen = dlen + w
  end

  return dlen
end

-- Get the UTF-8 character at the byte position.
function M.get_char_at_bytepos(line, bytepos)
  local char_id = M.get_char_index_at_bytepos(line, bytepos)
  return utf8.sub(line, char_id, char_id)
end

-- Get the UTF-8 character index at the byte position. This is necessary because
-- the byte position returned by `nvim_win_get_cursor` is related to the number
-- of bytes. Since UTF-8 characters can have multiple bytes, then we need to
-- take this into account when obtaining the UTF-8 character index on which the
-- byte is.
function M.get_char_index_at_bytepos(line, bytepos)
  local bs = 1
  local bytes = string.len(line)
  local char_id = 1

  while bs <= bytes do
    if bs >= bytepos then
      return char_id
    end

    bs = utf8.next(line, bs)
    char_id = char_id + 1
  end

  return char_id
end

return M
