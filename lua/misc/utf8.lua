-- Description -----------------------------------------------------------------------------
--
-- Miscellaneous functions related to UTF-8 strings.
--
-- -----------------------------------------------------------------------------------------

local M = {}

local utf8 = require('utf8.utf8')
local wcwidth = require('wcwidth.init')

--- Compute the display length of a string.
--
-- @param str String.
-- @return Display length of `str`.
function M.display_len(str)
  local dlen = 0

  for _, c in utf8.codes(str) do
    local w = wcwidth(utf8.codepoint(c))

    if w < 0 then
      return -1
    end

    dlen = dlen + w
  end

  return dlen
end

return M
