-- Description -----------------------------------------------------------------------------
--
-- TeX snippets related to figures.
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

return {
  s(
    {
      trig = "fig",
      desc = "Figure",
    },
    fmta(
      "\\begin{figure<>}<>\n" ..
      "\t\\begin{center}\n" ..
      "\t\t\\includegraphics[width=0.95\\textwidth]{./figs/<>}\n" ..
      "\t\\end{center}\n" ..
      "\t\\caption{<>}\n" ..
      "\t\\label{fig:<>}\n" ..
      "\\end{figure<>}\n",
      { c(1, { t(""), t("*") }), i(2, "[htbp]"), i(3), i(4), i(5), rep(1) }
    )
  ),
}
