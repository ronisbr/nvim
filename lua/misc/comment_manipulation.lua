-- Description -----------------------------------------------------------------------------
--
-- Functions to manipulate comments.
--
-- -----------------------------------------------------------------------------------------

local M = {}

--- Wrap the Julia comment in the current line inside a block.
--
-- Note that the current line will be **replaced** by the comment block.
function M.wrap_julia_comment_in_block()
  local tw = vim.o.textwidth

  if tw <= 0 then
    return nil
  end

  -- Get the buffer of the current window.
  local buf = vim.api.nvim_win_get_buf(0)

  -- Get the cursor position.
  local cur_pos = vim.api.nvim_win_get_cursor(0)

  -- Get the line text.
  local line = vim.api.nvim_buf_get_lines(buf, cur_pos[1] - 1, cur_pos[1], true)

  -- Let's take the comment in the current line.
  -- TODO: Replace with treesitter.
  local comment = string.match(line[1], "[^#]*#[#%s]*(.*)")

  if comment ~= nil then
    local cw = vim.fn.strdisplaywidth(comment)
    local indent = vim.fn.indent(cur_pos[1])

    if (tw - cw - indent - 4) > 0 then
      local lpad = math.floor((tw - cw - indent - 2) / 2)
      local rpad = tw - cw - indent - 2 - lpad

      local istr = string.rep(" ", indent)
      local lstr = string.rep(" ", lpad)
      local rstr = string.rep(" ", rpad)

      local bar = istr .. string.rep("#", tw - indent)
      local str = istr .. "#" .. lstr .. comment .. rstr .. "#"

      vim.api.nvim_buf_set_lines(buf, cur_pos[1] - 1, cur_pos[1], true, { bar, str, bar })
    end
  end
end

return M

