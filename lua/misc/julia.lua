-- Description -----------------------------------------------------------------------------
--
-- General functions to manipulate text in Julia files.
--
--------------------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------------------
--                                   Private Functions                                    --
--------------------------------------------------------------------------------------------

--- Join a Julia function / macro delacarion in `input` into a one line declaration.
---
--- @param input string Function declaration.
--- @return string Function declaration in one line.
local function join_function_declaration(input)
  -- Output text that contains the function declaration in one line.
  local func_decl = ""

  -- First, concatenate all lines into one string.
  for v in input:gmatch("[^\r\n]+") do
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

  -- Remove the word `function` and change `macro` to `@`.
  if (func_decl:find("^function[%s]*") ~= nil) then
    func_decl = func_decl:gsub("^function[%s]*", "")
  elseif (func_decl:find("^macro[%s]*") ~= nil) then
    func_decl = func_decl:gsub("^macro[%s]*", "@")
  end

  return func_decl
end

--- Place anchors for composed types in the string `str`.
---
--- This function replaces the text inside composed types like `Union{Nothing, FLoat64}` with
--- the anchor `!__TYPE_ANCHOR__!`. The replaced text is added to a table with is returned
--- together with the modified string. We used this function to pre-process the function
--- declaration so that we can split the arguments by searching for `,`.
---
--- @param func_decl string Function delcaration in one line.
--- @return string Modified string with the type anchors.
--- @return table Table with the snippets that were replaced.
local function place_composed_type_anchors(func_decl)
  local values = {}

  for v in string.gmatch(func_decl, "{([^}]*)}") do
    table.insert(values, v)
  end

  func_decl = string.gsub(func_decl, "{([^}]*)}", "{!__TYPE_ANCHOR__!}")

  return func_decl, values
end

--- Replace the keyword arguments in the one-line function declaration `func_decl` by
--- "kwargs...".
---
--- @param func_decl string Function declaration in one line.
--- @return string Function declaration without keyword arguments.
local function suppress_kwargs(func_decl)
  local func_decl_no_kwargs = func_decl:gsub(";.*", "; kwargs...)")
  return func_decl_no_kwargs
end

--- Remove the leading and trailing spaces from the string `str`.
---
--- @param str string Input string.
--- @return string Trimmed string.
local function trim_string(str)
  local trimmed_str = string.gsub(str, "^%s*(.-)%s*$", "%1")
  return trimmed_str
end

--- Create the list of arguments for the Julia function documentation given the function
--- delcaration in `func_decl`.
---
--- This function provides the full documentation version, including arguments, keywords,
--- and returns.
---
--- @params func_decl string Function declaration in one line.
--- @return table A string with the argument declaration.
local function create_args_info(func_decl)
  -- Get the function arguments and keywords.
  local parameters = string.match(func_decl, "%((.-)%)")

  -- Output table.
  local output = {}

  if (parameters == nil or parameters == "") then
    return output
  end

  -- Parse arguments.
  local args = string.match(parameters, "^([^;]*);?")

  if (args ~= nil) then

    -- First, we need to place the anchors for the compose types to remove constructions
    -- like `Union{Float64, Nothing}`. This procedure is required because we will filter for
    -- `,` to split the arguments afterwards.
    local type_anchor_values
    args, type_anchor_values = place_composed_type_anchors(args)
    local first_arg = true

    for v in string.gmatch(args, "([^,]+),?") do
      if (first_arg) then
        table.insert(output, "# Arguments")
        table.insert(output, "")
        first_arg = false
      end

      -- Remove trailing and leading spaces.
      v = trim_string(v)

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

      table.insert(output, "- `" .. v .. "`: <++>")

      -- If we have default value, add the information to the node.
      if dv ~= nil then
        -- Remove trailing and leading spaces from the default value.
        dv = string.gsub(dv, "^%s*(.-)%s*$", "%1")

        table.insert(output, "    (**Default**: " .. dv .. ")")
      end
    end
  end

  -- Parse keywords.
  local kwargs = string.gsub(parameters, "^([^;]*);?", "")

  if (kwargs ~= nil) then

    -- First, we need to place the anchors for the compose types to remove constructions
    -- like `Union{Float64, Nothing}`. This procedure is required because we will filter for
    -- `,` to split the arguments afterwards.
    local type_anchor_values
    kwargs, type_anchor_values = place_composed_type_anchors(kwargs)
    local first_kwarg = true

    for v in string.gmatch(kwargs, "([^,]+),?") do
      if (first_kwarg) then
        if (next(output) ~= nil) then
          table.insert(output, "")
        end

        table.insert(output, "# Keywords")
        table.insert(output, "")
        first_kwarg = false
      end

      -- Remove trailing and leading spaces.
      v = trim_string(v)

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

      table.insert(output, "- `" .. v .. "`: <++>")

      -- If we have default value, add the information to the node.
      if dv ~= nil then
        -- Remove trailing and leading spaces from the default value.
        dv = string.gsub(dv, "^%s*(.-)%s*$", "%1")

        table.insert(output, "    (**Default**: `" .. dv .. "`)")
      end
    end
  end

  return output
end

--- Create the Julia function documentation.
---
--- @params input string String with the Julia declaration.
--- @return table Table with the Julia declaration.
local function create_julia_func_doc(input)
  local func_decl = join_function_declaration(input)

  local output = {}

  -- Function declaration.
  table.insert(output, '"""')
  table.insert(output, "    " .. suppress_kwargs(func_decl) .. " -> <++>")
  table.insert(output, "")
  table.insert(output, "<++>")
  table.insert(output, "")

  -- Arguments.
  local args = create_args_info(func_decl)

  if (next(args) ~= nil) then
    for _, v in ipairs(args) do
      table.insert(output, v)
    end
  end

  table.insert(output, '"""')

  return output
end

--------------------------------------------------------------------------------------------
--                                    Public Functions                                    --
--------------------------------------------------------------------------------------------

--- Given the selected Julia function in visual mode, insert the documentation at the cursor
--- position.
function M.insert_julia_func_doc(start_line, end_line)
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
  local input = ""

  for _, v in ipairs(lines) do
    input = input .. v .. "\n"
  end

  if (input == "") then
    return
  end

  -- Create Julia function documentation.
  local julia_func_doc = create_julia_func_doc(input)

  -- Move the cursor to the beginning of start line and add the documentation.
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  vim.api.nvim_put(julia_func_doc, "l", false, false)
end

--- Setup the miscellaneous Julia functions.
function M.setup()
  vim.api.nvim_create_user_command(
    "JuliaFunctionDocumentation",
    function(t)
      require("misc/julia").insert_julia_func_doc(t.line1, t.line2)
    end,
    { range = true }
  )
end

return M
