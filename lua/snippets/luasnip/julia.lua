-- Description -----------------------------------------------------------------------------
--
-- Julia language configuration for LuaSnip.
--
-- -----------------------------------------------------------------------------------------

local M = {}

local ls = require("luasnip")
local utf8_misc = require("misc.utf8")

-- Auxiliary Functions ---------------------------------------------------------------------

--- Join the Julia function declaration lines in the table `selected_text` into one line.
function M.join_function_declaration(selected_text)
  -- Output text that contains the function declaration in one line.
  local func_decl = ""

  -- First, concatenate all lines into one string.
  for k, v in pairs(selected_text) do
    -- Strip all multiple spaces.
    v = string.gsub(v, "%s+", " ")

    -- Remove spaces in the beginning and in the end.
    v = string.gsub(v, "^%s*(.-)%s*$", "%1")

    if (v ~= "") then
      -- Check if we need to add a space before concatenating the string.
      if (func_decl ~= "") then
        local last_char = string.sub(func_decl, -1)

        if ((last_char ~= "(") and (last_char ~= "{")) then
          local first_char = string.sub(v, 1, 1)

          if ((first_char ~= ")") and (first_char ~= "}")) then
            func_decl = func_decl .. " "
          end
        end
      end

      func_decl = func_decl .. v
    end
  end

  -- Remove all spaces from the beginning.
  func_decl = string.gsub(func_decl, "%s+", " ")

  -- If the first word is `function`, then just remove it.
  func_decl = string.gsub(func_decl, "^function ", "")

  -- If the first word is `macro`, then replace it with `@`.
  func_decl = string.gsub(func_decl, "^macro ", "@")

  return func_decl
end

--- Place anchors for composed types in the string `str`.
--
-- This function replaces the text inside composed types like `Union{Nothing, FLoat64}` with
-- the anchor `!__TYPE_ANCHOR__!`. The replaced text is added to a table with is returned
-- together with the modified string. We used this function to pre-process the function
-- declaration so that we can split the arguments by searching for `,`.
--
-- @param str Function delcaration
-- @returns Modified string with the type anchors.
-- @returns Table with the snippets that were replaced.
function M.place_composed_type_anchors(str)
  local values = {}

  for v in string.gmatch(str, "{([^}]*)}") do
    table.insert(values, v)
  end

  str = string.gsub(str, "{([^}]*)}", "{!__TYPE_ANCHOR__!}")

  return str, values
end

--- Remove the keywords from the Julia function declaration, replacing by `kwargs...`.
function M.remove_keywords(func_decl)
  -- Check if we have keywords.
  if (string.match(func_decl, ";")) then
    func_decl = string.gsub(func_decl, ";(.-)%)", "; kwargs...)")
  end

  return func_decl
end

--- Remove the leading and trailing spaces from the string `str`.
function M.trim_string(str)
  return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

-- Snippet Functions -----------------------------------------------------------------------

--- Create the LuaSnip nodes that centers the input from `args` into a Julia comment block.
function M.luasnip_center_block(args)
  -- Get the current text width.
  local tw = vim.o.textwidth

  -- If the input is nil or if the text width is not set, we should do nothing.
  if ((args[1][1] == nil) or (tw <= 0)) then
    return ls.snippet_node(nil, {})
  end

  local nodes = {}

  if args[1][1] ~= nil then
    local str = args[1][1]
    local dw = utf8_misc.display_len(str)

    -- Only align if we have space.
    if dw < (tw - 2) then
      local lpad = math.floor((tw - 2 - dw) / 2)
      local rpad = tw - 2 - dw - lpad

      local lstr = string.rep(" ", lpad)
      local rstr = string.rep(" ", rpad)

      nodes[1] = ls.text_node({"", ""})
      nodes[2] = ls.text_node(string.rep("#", tw))
      nodes[3] = ls.text_node({"", ""})
      nodes[4] = ls.text_node("#" .. lstr .. str .. rstr .. "#")
      nodes[5] = ls.text_node({"", ""})
      nodes[6] = ls.text_node(string.rep("#", tw))
    end
  end

  return ls.snippet_node(nil, nodes)
end

--- Create the LuaSnip argument nodes for a Julia function declaration.
--
-- This function provides the full documentation version, including arguments, keywords, and
-- returns.
--
-- @params func_decl Function declaration in one line.
-- @params init_p Initial placeholder.
-- @returns LuaSnip argument nodes.
function M.luasnip_argument_nodes(func_decl, init_p)
  -- Nodes related to the arguments.
  local args_nodes = {}

  -- Nodes related to the keywords.
  local kwargs_nodes = {}

  -- Get the function arguments and keywords.
  local parameters = string.match(func_decl, "%((.-)%)")

  local k

  -- Parse arguments.
  local args = string.match(parameters, "^([^;]*);?")

  if (args ~= nil) then
    k = 1

    -- First, we need to place the anchors for the compose types to remove constructions
    -- like `Union{Float64, Nothing}`. This procedure is required because we will filter for
    -- `,` to split the arguments afterwards.
    local type_anchor_values
    args, type_anchor_values = M.place_composed_type_anchors(args)

    for v in string.gmatch(args, "([^,]+),?") do
      -- Remove trailing and leading spaces.
      v = M.trim_string(v)

      -- Get the default value, if any.
      local dv = string.match(v, "%s*=%s*(.*)")

      -- Remove default value, if any.
      v = string.gsub(v, "%s*=.*", "")

      -- Check if we have a composed type here. If so, replace the anchor with the type
      -- value.
      if (#type_anchor_values >= 1) and (string.match(v, "!__TYPE_ANCHOR__!") ~= nil) then
        v = string.gsub(v, "!__TYPE_ANCHOR__!", type_anchor_values[1], 1)
        table.remove(type_anchor_values, 1)
      end

      args_nodes[k] = ls.text_node("- `" .. v .. "`: ")
      k = k + 1

      args_nodes[k] = ls.insert_node(init_p)
      k = k + 1

      -- If we have default value, add the information to the node.
      if dv ~= nil then
        -- Remove trailing and leading spaces from the default value.
        dv = string.gsub(dv, "^%s*(.-)%s*$", "%1")

        args_nodes[k] = ls.text_node({ "", "" })
        k = k + 1

        args_nodes[k] = ls.text_node("    (**Default**: " .. dv .. ")")
        k = k + 1
      end

      args_nodes[k] = ls.text_node({ "", "" })
      k = k + 1

      init_p = init_p + 1
    end
  end

  -- Parse keywords.
  local kwargs = string.gsub(parameters, "^([^;]*);?", "")

  if (kwargs ~= nil) then
    k = 1

    -- First, we need to place the anchors for the compose types to remove constructions
    -- like `Union{Float64, Nothing}`. This procedure is required because we will filter for
    -- `,` to split the arguments afterwards.
    local type_anchor_values
    kwargs, type_anchor_values = M.place_composed_type_anchors(kwargs)

    for v in string.gmatch(kwargs, "([^,]+),?") do
      -- Remove trailing and leading spaces.
      v = M.trim_string(v)

      -- Get the default value, if any.
      local dv = string.match(v, "%s*=%s*(.*)")

      -- Remove default value, if any.
      v = string.gsub(v, "%s*=.*", "")

      -- Check if we have a composed type here. If so, replace the anchor with the type
      -- value.
      if ((#type_anchor_values >= 1) and (string.match(v, "!__TYPE_ANCHOR__!") ~= nil)) then
        v = string.gsub(v, "!__TYPE_ANCHOR__!", type_anchor_values[1], 1)
        table.remove(type_anchor_values, 1)
      end

      kwargs_nodes[k] = ls.text_node("- `" .. v .. "`: ")
      k = k + 1

      kwargs_nodes[k] = ls.insert_node(init_p)
      k = k + 1

      -- If we have default value, add the information to the node.
      if dv ~= nil then
        -- Remove trailing and leading spaces from the default value.
        dv = string.gsub(dv, "^%s*(.-)%s*$", "%1")

        kwargs_nodes[k] = ls.text_node({ "", "" })
        k = k + 1

        kwargs_nodes[k] = ls.text_node(" (**Default**: " .. dv .. ")")
        k = k + 1
      end

      kwargs_nodes[k] = ls.text_node({ "", "" })
      k = k + 1

      init_p = init_p + 1
    end
  end

  -- Table to store all the nodes.
  local nodes = {}

  if next(args_nodes) ~= nil then
    table.insert(nodes, ls.text_node("# Arguments"))
    table.insert(nodes, ls.text_node({ "", "" }))
    table.insert(nodes, ls.text_node({ "", "" }))

    for n = 1, #args_nodes do
      nodes[#nodes + 1] = args_nodes[n]
    end
  end

  if next(kwargs_nodes) ~= nil then
    if next(args_nodes) ~= nil then
      table.insert(nodes, ls.text_node({ "", "" }))
    end

    table.insert(nodes, ls.text_node("# Keywords"))
    table.insert(nodes, ls.text_node({ "", "" }))
    table.insert(nodes, ls.text_node({ "", "" }))

    for n = 1, #kwargs_nodes do
      nodes[#nodes + 1] = kwargs_nodes[n]
    end
  end

  return nodes, init_p
end

--- Create the LuaSnip documentation nodes for the Julia function declaration.
function M.luasnip_doc_nodes(selected_text)
  local func_decl = M.join_function_declaration(selected_text)
  local nodes = {}

  nodes[1] = ls.text_node({ '"""',"" })
  nodes[2] = ls.text_node({ "    " .. M.remove_keywords(func_decl), "" })
  nodes[3] = ls.text_node({ "", "" })
  nodes[4] = ls.insert_node(1)
  nodes[5] = ls.text_node({ "", "" })
  nodes[6] = ls.text_node({ "", "" })

  local args_nodes
  local p
  args_nodes, p = M.luasnip_argument_nodes(func_decl, 2)

  for k = 1, #args_nodes do
    nodes[#nodes + 1] = args_nodes[k]
  end

  nodes[#nodes + 1] = ls.text_node({ "", "" })
  nodes[#nodes + 1] = ls.text_node({ "# Returns", "" })
  nodes[#nodes + 1] = ls.text_node({ "", "" })
  nodes[#nodes + 1] = ls.insert_node(p)
  nodes[#nodes + 1] = ls.text_node({ "", "" })

  nodes[#nodes + 1] =ls.text_node({ '"""', "" })

  for k = 1, #selected_text do
    nodes[#nodes + 1] = ls.text_node(selected_text[k])
    nodes[#nodes + 1] = ls.text_node({ "", "" })
  end

  local snip = ls.snippet_node(nil, nodes)
  return snip
end

--- Create the LuaSnip doc. nodes for the Julia function declaration without the return.
function M.luasnip_doc_nodes_without_return(selected_text)
  local func_decl = M.join_function_declaration(selected_text)
  local nodes = {}

  nodes[1] = ls.text_node({ '"""',"" })
  nodes[2] = ls.text_node({ "    " .. M.remove_keywords(func_decl), "" })
  nodes[3] = ls.text_node({ "", "" })
  nodes[4] = ls.insert_node(1)
  nodes[5] = ls.text_node({ "", "" })
  nodes[6] = ls.text_node({ "", "" })

  local args_nodes
  local p
  args_nodes, p = M.luasnip_argument_nodes(func_decl, 2)

  for k = 1, #args_nodes do
    nodes[#nodes + 1] = args_nodes[k]
  end

  nodes[#nodes + 1] =ls.text_node({ '"""', "" })

  for k = 1, #selected_text do
    nodes[#nodes + 1] = ls.text_node(selected_text[k])
    nodes[#nodes + 1] = ls.text_node({ "", "" })
  end

  local snip = ls.snippet_node(nil, nodes)
  return snip
end

--- Create the LuaSnip doc. nodes for the Julia function declaration without any fields.
function M.luasnip_doc_nodes_without_fields(selected_text)
  local func_decl = M.join_function_declaration(selected_text)
  local nodes = {}

  nodes[1] = ls.text_node({ '"""', "" })
  nodes[2] = ls.text_node({ "    " .. M.remove_keywords(func_decl), "" })
  nodes[3] = ls.text_node({ "", "" })
  nodes[4] = ls.insert_node(1)
  nodes[5] = ls.text_node({ "", "" })
  nodes[6] = ls.text_node({ '"""', "" })

  for k = 1, #selected_text do
    nodes[#nodes + 1] = ls.text_node(selected_text[k])
    nodes[#nodes + 1] = ls.text_node({ "", "" })
  end

  local snip = ls.snippet_node(nil, nodes)
  return snip
end

-- Snippets Configuration ------------------------------------------------------------------

function M.config()
  ls.add_snippets(
    "julia", {
      -- Julia Comment Block ---------------------------------------------------------------

      ls.snippet({
        trig = "jlcblk",
        dscr = "Julia Comment Block",
        docstring = {
          "###############################",
          "#            Comment          #",
          "###############################",
        }
      }, {
          ls.insert_node(0),
          ls.insert_node(1),
          ls.dynamic_node(2, M.luasnip_center_block, 1)
        }),

      -- Julia Function Documentation ------------------------------------------------------

      ls.snippet({
        trig = "jld",
        dscr = "Julia Function Documentation",
        docstring = {
          '"""',
          "    test(a::Int, b::String; kwargs...)",
          "",
          "$1",
          "",
          "# Arguments",
          "",
          "- `a::Int`: $2",
          "- `b::String`: $3",
          "",
          "# Keywords",
          "",
          "- `c::Int`: $4",
          "- `d::Int`: $5",
          "",
          "# Returns",
          "",
          "$6",
          '"""',
          "function test(a::Int, b::String; c::Int = 1, d::Int = 2)",
          "$0",
        }
      }, { ls.dynamic_node(
          1,
          function(args, snip, old_state, initial_text)
            return M.luasnip_doc_nodes(snip.env.SELECT_RAW)
          end,
          {},
          ""
        ) }),

      -- Julia Function Documentation Without Return ---------------------------------------

      ls.snippet({
        trig = "jldnr",
        dscr = "Julia Function Documentation Without Return",
        docstring = {
          '"""',
          "    test(a::Int, b::String; kwargs...)",
          "",
          "$1",
          "",
          "# Arguments",
          "",
          "- `a::Int`: $2",
          "- `b::String`: $3",
          "",
          "# Keywords",
          "",
          "- `c::Int`: $4",
          "- `d::Int`: $5",
          '"""',
          "function test(a::Int, b::String; c::Int = 1, d::Int = 2)",
          "$0",
        }
      }, { ls.dynamic_node(
          1,
          function(args, snip, old_state, initial_text)
            return M.luasnip_doc_nodes_without_return(snip.env.SELECT_RAW)
          end,
          {},
          ""
        ) }),

      -- Julia Function Documentation Without Any Fields -----------------------------------

      ls.snippet({
        trig = "jldnf",
        dscr = "Julia Function Documentation Without Any Fields",
        docstring = {
          '"""',
          "    test(a::Int, b::String; kwargs...)",
          "",
          "$1",
          '"""',
          "function test(a::Int, b::String; c::Int = 1, d::Int = 2)",
          "$0",
        }
      }, { ls.dynamic_node(
          1,
          function(args, snip, old_state, initial_text)
            return M.luasnip_doc_nodes_without_fields(snip.env.SELECT_RAW)
          end,
          {},
          ""
        ) }),
    }
  )
end

return M
