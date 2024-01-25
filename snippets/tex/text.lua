-- Description -----------------------------------------------------------------------------
--
-- TeX snippets related to text environments.
--
--------------------------------------------------------------------------------------------

local ls   = require("luasnip")

-- Auxiliary functions and variables -------------------------------------------------------

local as   = ls.extend_decorator.apply(s, { snippetType = "autosnippet" })
local d    = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta
local i    = ls.insert_node
local rep  = require("luasnip.extras").rep
local s    = ls.snippet
local sn   = ls.snippet_node
local t    = ls.text_node

local make_condition     = require("luasnip.extras.conditions").make_condition
local tex_utils          = require("snippets.luasnip.tex")
local luasnip_in_bullets = make_condition(tex_utils.in_bullets)
local luasnip_line_begin = require("luasnip.extras.conditions.expand").line_begin

return {

  s(
    {
      trig = "enum",
      desc = "Numbered list (enumerate)"
    },
    fmta(
      "\\begin{enumerate}\n" ..
      "\t\\item <>\n" ..
      "\\end{enumerate}\n",
      { i(1) }
    )
  ),

  s(
    {
      trig = "item",
      desc = "Bullet points (itemize)"
    },
    fmta(
      "\\begin{itemize}\n" ..
      "\t\\item <>\n" ..
      "\\end{itemize}\n",
      { i(1) }
    )
  ),

  as(
    {
      trig = "--",
      hidden = true
    },
    {
      t("\\item")
    },
    {
      condition = luasnip_in_bullets * luasnip_line_begin,
      show_condition = luasnip_in_bullets * luasnip_line_begin
    }
  ),

  s(
    {
      trig = "beg",
      desc = "begin/end environment (generic)"
    },
    fmta(
      "\\begin{<>}\n" ..
      "\t<>\n" ..
      "\\end{<>}",
      {i(1), i(2), rep(1)}
    )
  ),

  s(
    {
      trig = "ref",
      desc = "Reference"
    },
    fmta("\\ref{<>}", i(1))
  ),

  s(
    {
      trig = "eqref",
      desc = "Equation reference"
    },
    fmta("\\eqref{<>}", i(1))
  ),

  s(
    {
      trig = "bf",
      desc = "Bold text"
    },
    d(
      1,
      function(_, snip)
        -- HACK: The Neovim API returns the cursor position before expanding the snippet.
        -- However, when we check the current node in tree sitter, we are in the stage after
        -- the expansion. Hence, we need to move the cursor to account for the snippet
        -- trigger that was deleted.
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1
        col = (col >= 2) and (col - 2) or col

        if not tex_utils.in_math({ pos = { row, col } }) then
          return sn(nil, fmta("\\textbf{<>}", { i(1, snip.env.SELECT_RAW) }))
        else
          return sn(nil, fmta("\\mathbf{<>}", { i(1, snip.env.SELECT_RAW) }))
        end
      end,
      {},
      ""
    )
  ),

  s(
    {
      trig = "it",
      desc = "Italic text"
    },
    d(
      1,
      function(_, snip)
        return sn(nil, fmta("\\textit{<>}", { i(1, snip.env.SELECT_RAW) }))
      end,
      {},
      ""
    )
  ),

  s(
    {
      trig = "tt",
      desc = "Monospace text"
    },
    d(
      1,
      function(_, snip)
        return sn(nil, fmta("\\texttt{<>}", { i(1, snip.env.SELECT_RAW) }))
      end,
      {},
      ""
    )
  ),
}
