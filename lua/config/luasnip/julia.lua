-- Snippets for Julia language
-- ============================================================================

local M = {}

local ls    = require("luasnip")
local s     = ls.snippet
local sn    = ls.snippet_node
local t     = ls.text_node
local i     = ls.insert_node
local f     = ls.function_node
local c     = ls.choice_node
local d     = ls.dynamic_node
local r     = ls.restore_node
local l     = require("luasnip.extras").lambda
local rep   = require("luasnip.extras").rep
local p     = require("luasnip.extras").partial
local m     = require("luasnip.extras").match
local n     = require("luasnip.extras").nonempty
local dl    = require("luasnip.extras").dynamic_lambda
local fmt   = require("luasnip.extras.fmt").fmt
local fmta  = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

-- =============================================================================
-- Auxiliary functions
-- =============================================================================

-- Convert the table `selected_text` with the selected lines into a Julia
-- function declaration in one line.
function M.julia_func_decl_oneline(selected_text)
  -- Output text that contains the function declaration in one line.
  func_decl = ""

  -- First, concatenate all lines into one string.
  for k, v in pairs(selected_text) do
    -- Strip all multiple spaces.
    v = string.gsub(v, '%s+', ' ')

    -- Remove spaces in the beginning and in the end.
    v = string.gsub(v, '^%s*(.-)%s*$', '%1')

    if (v == '') then
      goto continue
    end

    -- Check if we need to add a space before concatenating the string.
    if (func_decl ~= '') then
      last_char = string.sub(func_decl, -1)

      if ((last_char ~= '(') and (last_char ~= '{')) then
        first_char = string.sub(v, 1, 1)

        if ((first_char ~= ')') and (first_char ~= '}')) then
          func_decl = func_decl .. ' '
        end
      end
    end

    func_decl = func_decl .. v

    ::continue::
  end

  -- Remove all spaces from the beginning.
  func_decl = string.gsub(func_decl, '%s+', ' ')

  -- If the first word is `function`, then just remove it.
  func_decl = string.gsub(func_decl, '^function ', '')

  -- If the first word is `macro`, then replace it with `@`.
  func_decl = string.gsub(func_decl, '^macro ', '@')

  return func_decl
end

-- Remove the keywords from the Julia function declaration, replacing by
-- `kwargs...`.
function M.julia_func_decl_remove_kwargs(func_decl)
  -- Check if we have keywords.
  if (string.match(func_decl, ';')) then
    func_decl = string.gsub(func_decl, ';(.-)%)', '; kwargs...)')
  end

  return func_decl
end

-- Create the LuaSnip nodes containing the arguments and keywords for the Julia
-- function declaration `func_decl` and the initial placeholder `init_p`. It
-- returns the nodes and the current placeholder.
function M.julia_create_arguments_nodes(func_decl, init_p)
  -- Nodes related to the arguments.
  local args_nodes = {}

  -- Nodes related to the keywords.
  local kwargs_nodes = {}

  -- Get the function arguments and keywords.
  parameters = string.match(func_decl, '%((.-)%)')

  local k

  -- Parse arguments.
  args = string.match(parameters, '^([^;]*);?')

  if (args ~= nil) then
    k = 1
    for v in string.gmatch(args, '([^,]+),?') do
      -- Remove trailing and leading spaces.
      v = string.gsub(v, '^%s*(.-)%s*$', '%1')

      -- If we find a `=`, then we have a keyword.
      args_nodes[k]     = t('- `' .. v .. '`: ')
      args_nodes[k + 1] = i(init_p)
      args_nodes[k + 2] = t({'', ''})
      k = k + 3
      init_p = init_p + 1
    end
  end

  -- Parse keywords.
  kwargs = string.gsub(parameters, '^([^;]*);?', '')

  if (kwargs ~= nil) then
    k = 1
    for v in string.gmatch(kwargs, '([^,]+),?') do
      -- Remove trailing and leading spaces.
      v = string.gsub(v, '^%s*(.-)%s*$', '%1')

      v = string.gsub(v, '%s*=.*', '')
      kwargs_nodes[k]     = t('- `' .. v .. '`: ')
      kwargs_nodes[k + 1] = i(init_p)
      kwargs_nodes[k + 2] = t({'', ''})
      k = k + 3
      init_p = init_p + 1
    end
  end

  local nodes = {}

  if next(args_nodes) ~= nil then
    table.insert(nodes, t("# Args"))
    table.insert(nodes, t({"", ""}))
    table.insert(nodes, t({"", ""}))

    for k = 1, #args_nodes do
      nodes[#nodes + 1] = args_nodes[k]
    end
  end

  if next(kwargs_nodes) ~= nil then
    if next(args_nodes) ~= nil then
      table.insert(nodes, t({"", ""}))
    end

    table.insert(nodes, t("# Keywords"))
    table.insert(nodes, t({"", ""}))
    table.insert(nodes, t({"", ""}))

    for k = 1, #kwargs_nodes do
      nodes[#nodes + 1] = kwargs_nodes[k]
    end
  end

  return nodes, init_p
end

-- Create the LuaSnip nodes for the Julia function documentation with all
-- fields.
function M.julia_doc_nodes(selected_text)
  local func_decl = M.julia_func_decl_oneline(selected_text)
  local nodes = {}
  local p = 1

  nodes[1] = t({'"""',''})
  nodes[2] = t({'    ' .. M.julia_func_decl_remove_kwargs(func_decl), ''})
  nodes[3] = t({'', ''})
  nodes[4] = i(p)
  nodes[5] = t({'', ''})
  nodes[6] = t({'', ''})

  args_nodes, p = M.julia_create_arguments_nodes(func_decl, p + 1)

  for k = 1, #args_nodes do
    nodes[#nodes + 1] = args_nodes[k]
  end

  nodes[#nodes + 1] = t({'', ''})
  nodes[#nodes + 1] = t({'# Returns', ''})
  nodes[#nodes + 1] = t({'', ''})
  nodes[#nodes + 1] = i(p)
  nodes[#nodes + 1] = t({'', ''})

  nodes[#nodes + 1] = t({'"""', ''})

  for k = 1, #selected_text do
    nodes[#nodes + 1] = t(selected_text[k])
    nodes[#nodes + 1] = t({'', ''})
  end

  local snip = sn(nil, nodes)
  return snip
end

-- Create the LuaSnip nodes for the Julia function documentation with all
-- fields expect for the return section.
function M.julia_doc_noreturn_nodes(selected_text)
  local func_decl = M.julia_func_decl_oneline(selected_text)
  local nodes = {}
  local p = 1

  nodes[1] = t({'"""',''})
  nodes[2] = t({'    ' .. M.julia_func_decl_remove_kwargs(func_decl), ''})
  nodes[3] = t({'', ''})
  nodes[4] = i(p)
  nodes[5] = t({'', ''})
  nodes[6] = t({'', ''})

  args_nodes, p = M.julia_create_arguments_nodes(func_decl, p + 1)

  for k = 1, #args_nodes do
    nodes[#nodes + 1] = args_nodes[k]
  end

  nodes[#nodes + 1] = t({'"""', ''})

  for k = 1, #selected_text do
    nodes[#nodes + 1] = t(selected_text[k])
    nodes[#nodes + 1] = t({'', ''})
  end

  local snip = sn(nil, nodes)
  return snip
end

-- Create the LuaSnip nodes for the Julia function documentation without any
-- fields.
function M.julia_doc_nofields_nodes(selected_text)
  local func_decl = M.julia_func_decl_oneline(selected_text)
  local nodes = {}
  local p = 1

  nodes[1] = t({'"""',''})
  nodes[2] = t({'    ' .. M.julia_func_decl_remove_kwargs(func_decl), ''})
  nodes[3] = t({'', ''})
  nodes[4] = i(p)
  nodes[5] = t({'', ''})
  nodes[6] = t({'"""', ''})

  for k = 1, #selected_text do
    nodes[#nodes + 1] = t(selected_text[k])
    nodes[#nodes + 1] = t({'', ''})
  end

  local snip = sn(nil, nodes)
  return snip
end

-- =============================================================================
-- Snippets configuration
-- =============================================================================

function M.config()
  ls.add_snippets(
    "julia", {
      -- Julia function documentation
      -- -----------------------------------------------------------------------
      s({
        trig = 'jld',
        dscr = 'Julia function documentation',
        docstring = {
          '"""',
          '    test(a::Int, b::String; kwargs...)',
          '',
          '$1',
          '',
          '# Args',
          '',
          '- `a::Int`: $2',
          '- `b::String`: $3',
          '',
          '# Keywords',
          '',
          '- `c::Int`: $4',
          '- `d::Int`: $5',
          '',
          '# Returns',
          '',
          '$6',
          '"""',
          'function test(a::Int, b::String; c::Int = 1, d::Int = 2)',
          '$0',
        }
      }, {
        d(
          1,
          function(args, snip, old_state, initial_text)
            return M.julia_doc_nodes(snip.env.SELECT_RAW)
          end,
          {},
          ''
        )
      }),

      -- Julia function documentation (without return)
      -- -----------------------------------------------------------------------
      s({
        trig = 'jldnr',
        dscr = 'Julia function documentation (without return)',
        docstring = {
          '"""',
          '    test(a::Int, b::String; kwargs...)',
          '',
          '$1',
          '',
          '# Args',
          '',
          '- `a::Int`: $2',
          '- `b::String`: $3',
          '',
          '# Keywords',
          '',
          '- `c::Int`: $4',
          '- `d::Int`: $5',
          '"""',
          'function test(a::Int, b::String; c::Int = 1, d::Int = 2)',
          '$0',
        }
      }, {
        d(
          1,
          function(args, snip, old_state, initial_text)
            return M.julia_doc_noreturn_nodes(snip.env.SELECT_RAW)
          end,
          {},
          ''
        )
      }),

      -- Julia function documentation (without any fields)
      -- -----------------------------------------------------------------------
      s({
        trig = 'jldnf',
        dscr = 'Julia function documentation (without any fields)',
        docstring = {
          '"""',
          '    test(a::Int, b::String; kwargs...)',
          '',
          '$1',
          '"""',
          'function test(a::Int, b::String; c::Int = 1, d::Int = 2)',
          '$0',
        }
      }, {
        d(
          1,
          function(args, snip, old_state, initial_text)
            return M.julia_doc_nofields_nodes(snip.env.SELECT_RAW)
          end,
          {},
          ''
        )
      }),
    }
  )
end

return M
