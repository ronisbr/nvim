-- Description -----------------------------------------------------------------------------
--
-- Auxiliary functions to create snippets for TeX language. This module depends on
-- treesitter (with LaTeX grammar) and vimtex.
--
-- References ------------------------------------------------------------------------------
--
-- The code was adapted from https://github.com/evesdropper/luasnip-latex-snippets.nvim
--
-- -----------------------------------------------------------------------------------------

local M = {}

--- Return `true` if we are inside the environment `name` or `false` otherwise.
local function env(name)
	local is_inside = vim.fn["vimtex#env#is_inside"](name)
	return (is_inside[1] > 0 and is_inside[2] > 0)
end

--- Return `true` if we are inside the environments `itemize` or `enumerate`.
function M.in_bullets()
  return env("itemize") or env("enumerate")
end

--- Return `true` if we are in math environments or `false` otherwise.
--
-- @param opts Table with options to the function `vim.treesitter.get_node`.
function M.in_math(opts)
  -- We interate through all the current node's parents searching if any of them is a
  -- "math_environment" or "inline_formula".
  local current_node = vim.treesitter.get_node(opts)

  while true do
    if current_node == nil then
      return false
    else
      local ntype = current_node:type()
      if ((ntype == "math_environment") or (ntype == "inline_formula")) then
        return true
      else
        current_node = current_node:parent()
      end
    end
  end
end

--- Return `true` if we are in a tabular-like environment or `false` otherwise.
function M.in_table()
  return env("tabular") or env("tabularx") or env("tabulary") or env("longtable")
end

--- Return `true` if we are in text environment or `false` otherwise.
function M.in_text()
	return env("document") and not M.in_math()
end

return M
