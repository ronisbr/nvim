-- Description -----------------------------------------------------------------------------
--
-- Configuration of lualine.
--
-- -----------------------------------------------------------------------------------------

-- Local Variables -------------------------------------------------------------------------

-- Table to map the current mode into characters to be shown at the bar.
local vim_mode_map = {
  ["n"]     = " N ",
  ["no"]    = " O ",
  ["nov"]   = " O ",
  ["noV"]   = " O ",
  ["no\22"] = " O ",
  ["niI"]   = " N ",
  ["niR"]   = " N ",
  ["niV"]   = " N ",
  ["nt"]    = " N ",
  ["ntT"]   = " N ",
  ["v"]     = " V ",
  ["vs"]    = " V ",
  ["V"]     = "VL ",
  ["Vs"]    = "VL ",
  ["\22"]   = "VB ",
  ["\22s"]  = "VB ",
  ["s"]     = " S ",
  ["S"]     = "SL ",
  ["\19"]   = "SB ",
  ["i"]     = " I ",
  ["ic"]    = " I ",
  ["ix"]    = " I ",
  ["R"]     = " R ",
  ["Rc"]    = " R ",
  ["Rx"]    = " R ",
  ["Rv"]    = "VR ",
  ["Rvc"]   = "VR ",
  ["Rvx"]   = "VR ",
  ["c"]     = "CMD",
  ["cv"]    = "EX ",
  ["ce"]    = "EX ",
  ["r"]     = " R ",
  ["rm"]    = " M ",
  ["r?"]    = " C ",
  ["!"]     = " S ",
  ["t"]     = " T ",
}

-- Local Functions -------------------------------------------------------------------------

-- Return the lines and characters selected by the visual mode.
local function _get_visual_selection_information()
  local is_visual_mode = vim.fn.mode():find("[Vv]")
  local is_visual_block_mode = vim.fn.mode():find("[\22]")

  -- We only need to evaluate this function if we are in a visual mode.
  if not is_visual_mode and not is_visual_block_mode then
    return ""
  end

  -- Get the position of the initial visual mode selection.
  local vpos      = vim.fn.getpos("v")
  local begin_pos = { row = vpos[2], col = vpos[3] - 1 }

  -- Get the position of the cursor.
  local cursor  = vim.api.nvim_win_get_cursor(0)
  local end_pos = { row = cursor[1], col = cursor[2] }

  -- Compute the number of lines and columns between the beginning and end positions.
  local lines   = math.abs(end_pos.row - begin_pos.row) + 1
  local columns = math.abs(end_pos.col - begin_pos.col) + 1

  -- Assemble the text and return.
  if is_visual_mode then
    return "[" .. tostring(lines) .. "L]"
  elseif is_visual_block_mode then
    return "[" .. tostring(lines) .. "L " .. tostring(columns) .. "C]"
  end
end

-- Return the current mode.
local function _get_vim_mode_text()
  local mode_code = vim.api.nvim_get_mode().mode
  if vim_mode_map[mode_code] == nil then
    return mode_code
  end

  return vim_mode_map[mode_code]
end

-- Show the macro recording information.
local function _show_macro_recording()
  local recording_register = vim.fn.reg_recording()
  if recording_register == "" then
    return ""
  else
    return "● " .. recording_register
  end
end

-- Show the tab indicator.
local function _show_tab_indicator()
  local num_tabs = vim.fn.tabpagenr("$")

  if num_tabs <= 1 then
    return  ""
  end

  local current_tab = vim.fn.tabpagenr()
  return "[" .. tostring(current_tab) .. " / " .. tostring(num_tabs) .. "]"
end

-- Plugin Configuration --------------------------------------------------------------------

return {
  -- "nvim-lualine/lualine.nvim",
  -- event = "VeryLazy",
  --
  -- opts = {
  --   options = {
  --     -- Filetypes in which we will hide the bar.
  --     disabled_filetypes = {
  --       "alpha",
  --       "dashboard",
  --       "neo-tree",
  --       "noice",
  --       "starter",
  --     },
  --     component_separators = { left = "", right = "" },
  --     section_separators = { left = "", right = "" },
  --     theme = "nano-theme"
  --   },
  --
  --   -- The status bar will show only the buffer list.
  --   sections = {
  --     lualine_a = {},
  --
  --     lualine_b = {
  --       {
  --         "buffers",
  --         mode = 0,
  --         symbols = {
  --           alternate_file = "",
  --           modified = " [+]",
  --         }
  --       }
  --     },
  --
  --     lualine_c = {},
  --
  --     lualine_x = {},
  --
  --     lualine_y = {},
  --
  --     lualine_z = {},
  --   },
  --
  --   -- Set the winbar sections.
  --   winbar = {
  --     lualine_a = {
  --       {
  --         "vim_mode",
  --         fmt = _get_vim_mode_text,
  --       }
  --     },
  --
  --     lualine_b = {
  --       {
  --         "macro",
  --         fmt = _show_macro_recording,
  --       },
  --       { "filetype", },
  --       { "filename", },
  --     },
  --
  --     lualine_c = {
  --       { "branch", }
  --     },
  --
  --     lualine_x = {
  --       {
  --         "visual_selection",
  --         fmt = _get_visual_selection_information,
  --       }
  --     },
  --
  --     lualine_y = {
  --       -- This component is necessary to allow Neovide to keep the winbar fixed while
  --       -- scrolling with smooth scroll enabled.
  --       {
  --         "spacer",
  --         fmt = function ()
  --           return " "
  --         end
  --       },
  --       { "progress", },
  --       { "location", },
  --       {
  --         "current_tab",
  --         fmt = _show_tab_indicator,
  --       },
  --     },
  --
  --     lualine_z = {},
  --   },
  --
  --   inactive_winbar = {
  --     lualine_a = {
  --       {
  --         "inactive_mode",
  --         fmt = function()
  --           return "   "
  --         end
  --       }
  --     },
  --
  --     lualine_b = {
  --       { "filetype" },
  --       { "filename" },
  --     },
  --
  --     lualine_c = {
  --       { "branch" }
  --     },
  --
  --     lualine_x = {},
  --
  --     lualine_y = {},
  --
  --     lualine_z = {},
  --   },
  -- },
}

-- vim:ts=2:sts=2:sw=2:et
