-- Description -----------------------------------------------------------------------------
--
-- TeX snippets related to math.
--
--------------------------------------------------------------------------------------------

local ls   = require("luasnip")

-- Auxiliary functions and variables -------------------------------------------------------

local c    = ls.choice_node
local fmta = require("luasnip.extras.fmt").fmta
local i    = ls.insert_node
local rep  = require("luasnip.extras").rep
local s    = ls.snippet
local t    = ls.text_node

local tex_utils = require("snippets.luasnip.tex")

return {
  s(
    {
      trig = "aligned",
      desc = "Aligned environment"
    },
    fmta(
      "\\begin{aligned}\n" ..
      "\t<>\n" ..
      "\\end{aligned}\n",
      { i(1) }
    ),
    {
      condition      = tex_utils.in_math,
      show_condition = tex_utils.in_math
    }
  ),

  s(
    {
      trig = "eq",
      desc = "Equation"
    },
    fmta(
      "\\begin{equation<>}\n" ..
      "\t<>\n" ..
      "\t\\label{eq:<>}\n" ..
      "\\end{equation<>}\n",
      { c(1, { t(""), t("*") }), i(2), i(3), rep(1) }
    )
  ),

  s(
    {
      trig = "matrix",
      desc = "Matrix"
    },
    fmta(
      "\\begin{<>matrix}\n" ..
      "\t<>\n" ..
      "\\end{<>matrix}",
      { c(1, { t(""), t("p"), t("b"), t("B"), t("v"), t("V") } ), i(2), rep(1) }
    ),
    {
      condition      = tex_utils.in_math,
      show_condition = tex_utils.in_math
    }
  ),

  s(
    {
      trig = "mleq",
      desc = "Equation in multiple lines"
    },
    fmta(
      "\\begin{multline<>}\n" ..
      "\t<>\n" ..
      "\t\\label{eq:<>}\n" ..
      "\\end{multline<>}\n",
      { c(1, { t(""), t("*") }), i(2), i(3), rep(1) }
    )
  ),
}
