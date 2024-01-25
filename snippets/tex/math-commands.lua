-- Description -----------------------------------------------------------------------------
--
-- TeX snippets related to math commands.
--
--------------------------------------------------------------------------------------------

local ls   = require("luasnip")

-- Auxiliary functions and variables -------------------------------------------------------

local fmta = require("luasnip.extras.fmt").fmta
local i    = ls.insert_node
local s    = ls.snippet
local t    = ls.text_node

local tex_utils = require("snippets.luasnip.tex")

local M = {}

-- Math Commands without Arguments ---------------------------------------------------------

local math_commands_no_arg = {
  { "arcsin", "Arcsine" },
  { "arccos", "Arccosine" },
  { "arctan", "Arctangent" },
  { "sin",    "Sine" },
  { "cos",    "Cosine" },
  { "tan",    "Tangent" },
  { "sec",    "Secant" },
  { "csc",    "Cosecant" },
  { "cot",    "Cotangent" }
}

for k = 1, #math_commands_no_arg do
  local cmd = math_commands_no_arg[k]
  table.insert(
    M,
    s(
      {
        trig = cmd[1],
        desc = cmd[2]
      },
      t("\\" .. cmd[1]),
      {
        condition      = tex_utils.in_math,
        show_condition = tex_utils.in_math
      }
    )
  )
end

-- Math Commands with One Argument ---------------------------------------------------------

local math_commands_one_arg = {
  { "dot",  "Dot" },
  { "sqrt", "Square root" },
}

for k = 1, #math_commands_one_arg do
  local cmd = math_commands_one_arg[k]
  table.insert(
    M,
    s(
      {
        trig = cmd[1],
        desc = cmd[2]
      },
      fmta("\\" .. cmd[1] .. "{<>}", { i(1) }),
      {
        condition      = tex_utils.in_math,
        show_condition = tex_utils.in_math
      }
    )
  )
end

-- Math Commands with Two Arguments --------------------------------------------------------

local math_commands_two_args = {
  { "frac", "Fraction" },
}

for k = 1, #math_commands_two_args do
  local cmd = math_commands_two_args[k]
  table.insert(
    M,
    s(
      {
        trig = cmd[1],
        desc = cmd[2]
      },
      fmta("\\" .. cmd[1] .. "{<>}{<>}", { i(1), i(2) }),
      {
        condition      = tex_utils.in_math,
        show_condition = tex_utils.in_math
      }
    )
  )
end

-- Others ----------------------------------------------------------------------------------

table.insert(
  M,
  s(
    {
      trig = "deriv",
      desc = "Derivative"
    },
    fmta("\\frac{d<>}{d<>}", { i(1), i(2) }),
    {
      condition      = tex_utils.in_math,
      show_condition = tex_utils.in_math
    }
  )
)

table.insert(
  M,
  s(
    {
      trig = "int",
      desc = "Integral"
    },
    fmta("\\int_{<>}^{<>} <> d", { i(1), i(2), i(3) }),
    {
      condition      = tex_utils.in_math,
      show_condition = tex_utils.in_math
    }
  )
)

table.insert(
  M,
  s(
    {
      trig = "sum",
      desc = "Summation"
    },
    fmta("\\sum_{<>}^{<>}", { i(1), i(2) }),
    {
      condition      = tex_utils.in_math,
      show_condition = tex_utils.in_math
    }
  )
)

table.insert(
  M,
  s(
    {
      trig = "partial",
      desc = "Partial derivative"
    },
    fmta("\\frac{\\partial <>}{\\partial <>}", { i(1), i(2) }),
    {
      condition      = tex_utils.in_math,
      show_condition = tex_utils.in_math
    }
  )
)

return M
