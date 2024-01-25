-- Description -----------------------------------------------------------------------------
--
-- TeX snippets related to document sections.
--
--------------------------------------------------------------------------------------------

local ls   = require("luasnip")

-- Auxiliary functions and variables -------------------------------------------------------

local fmta = require("luasnip.extras.fmt").fmta
local i    = ls.insert_node
local s    = ls.snippet

--- Create a function to check if we are at the line beginning considering the `trigger`.
local function line_beginning(trigger)
  return function(line)
    return line:match("^[%s]*" .. trigger .. "$")
  end
end

return {
  s(
    {
      trig = "chap",
      desc = "Chapter (Level 0)"
    },
    fmta("\\chapter{<>}", { i(1) }),
    {
      condition      = line_beginning("chap"),
      show_condition = line_beginning("chap")
    }
  ),

  s(
    {
      trig = "sec",
      desc = "Section (Level 1)"
    },
    fmta("\\section{<>}", { i(1) }),
    {
      condition      = line_beginning("sec"),
      show_condition = line_beginning("sec")
    }
  ),

  s(
    {
      trig = "ssec",
      desc = "Subsection (Level 2)"
    },
    fmta("\\subsection{<>}", { i(1) }),
    {
      condition      = line_beginning("ssec"),
      show_condition = line_beginning("ssec")
    }
  ),

  s(
    {
      trig = "sssec",
      desc = "Subsubsection (Level 3)"
    },
    fmta("\\subsubsection{<>}", { i(1) }),
    {
      condition      = line_beginning("sssec"),
      show_condition = line_beginning("sssec")
    }
  ),
}
