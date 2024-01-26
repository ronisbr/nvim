-- Description -----------------------------------------------------------------------------
--
-- TeX snippets related to tables.
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
      trig = "ltab",
      desc = "Long table",
    },
    fmta(
      "\\begin{longtable<>}{<>}\n" ..
      "\t\\caption{<>}\n" ..
      "\t\\label{tab:<>} \\\\\n" ..
      "\t<>\n" ..
      "\t\\endfirsthead\n" ..
      "\t<>\n" ..
      "\t\\endhead\n" ..
      "\t<>\n" ..
      "\t\\endfoot\n" ..
      "\t<>\n" ..
      "\t\\endlastfoot\n" ..
      "\t<>\n" ..
      "\\end{longtable<>}\n" ..
      "<>",
      {
        c(1, { t(""), t("*") }),
        i(2),
        i(3),
        i(4),
        i(5, "First head"),
        i(6, "Head"),
        i(7, "Foot"),
        i(8, "Last foot"),
        i(9),
        rep(1),
        i(0)
      }
    )
  ),

  s(
    {
      trig = "mc",
      desc = "Multiple column cell"
    },
    fmta("\\multicolumn{<>}{<>}{<>}", { i(1, "1"), i(2, "c"), i(3) }),
    {
      condition = tex_utils.in_table,
      show_condition = tex_utils.in_table
    }
  ),

  s(
    {
      trig = "tab",
      desc = "Table",
    },
    fmta(
      "\\begin{table<>}<>\n" ..
      "\t\\caption{<>}\n" ..
      "\t\\label{tab:<>}\n" ..
      "\t\\begin{center}\n" ..
      "\t\t\\begin{tabular}{<>}\n" ..
      "\t\t\t<>\n"..
      "\t\t\\end{tabular}\n" ..
      "\t\\end{center}\n" ..
      "\\end{table<>}\n" ..
      "<>",
      { c(1, { t(""), t("*") }), i(2, "[htbp]"), i(3), i(4), i(5), i(6), rep(1), i(0) }
    )
  )
}
