-- Plugin configuration: lualine.nvim ------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Local Variables                                                                        --
--------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------
-- Local Functions                                                                        --
--------------------------------------------------------------------------------------------

-- Return the lines and characters selected by the visual mode.
local function get_visual_selection_information()
	local is_visual_mode = vim.fn.mode():find("[Vv]")
	if not is_visual_mode then return "" end

	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	local lines = start_line <= end_line and end_line - start_line + 1 or start_line - end_line + 1

	return "[" .. tostring(lines) .. "L " .. tostring(vim.fn.wordcount().visual_chars) .. "C]"
end

-- Return the current mode.
local function get_vim_mode_text()
  local mode_code = vim.api.nvim_get_mode().mode
  if vim_mode_map[mode_code] == nil then
    return mode_code
  end

  return vim_mode_map[mode_code]
end

-- Show the macro recording information.
local function show_macro_recording()
  local recording_register = vim.fn.reg_recording()
  if recording_register == "" then
    return ""
  else
    return "● " .. recording_register
  end
end

-- Show the tab indicator.
local function show_tab_indicator()
  local num_tabs = vim.fn.tabpagenr("$")

  if num_tabs <= 1 then
    return  ""
  end

  local current_tab = vim.fn.tabpagenr()
  return "[" .. tostring(current_tab) .. " / " .. tostring(num_tabs) .. "]"
end

--------------------------------------------------------------------------------------------
-- Plugin Configuration                                                                   --
--------------------------------------------------------------------------------------------

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",

  opts = {

    options = {
      -- Filetypes in which we will hide the bar.
      disabled_filetypes = {
        "alpha",
        "dashboard",
        "neo-tree",
        "noice",
        "starter",
      },
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      theme = "nano-theme",
    },

    -- We will show only the winbar (at top). Hence, let's remove all
    -- components from the status bar.
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },

    -- Set the winbar sections.
    winbar = {
      lualine_a = {
        {
          "vim_mode",
          fmt = get_vim_mode_text,
        }
      },

      lualine_b = {
        { "macro", fmt = show_macro_recording, },
        { "filetype", color = { gui = "bold" } },
        { "filename" },
      },

      lualine_c = {
        {
          "branch",
          color = function ()
            local c = require("nano-theme.colors").get()
            return { fg = c.nano_faded_color }
          end
        }
      },

      lualine_x = {
        {
          "visual_selection",
          color = function ()
            local c = require("nano-theme.colors").get()
            return { fg = c.nano_salient_color }
          end,
          fmt = get_visual_selection_information,
        }
      },

      lualine_y = {
        {
          "progress",
          color = function ()
            local c = require("nano-theme.colors").get()
            return { fg = c.nano_faded_color }
          end,
        },
        {
          "location",
          color = function ()
            local c = require("nano-theme.colors").get()
            return { fg = c.nano_faded_color }
          end,
        },
        {
          "current_tab",
          color = function ()
            local c = require("nano-theme.colors").get()
            return { fg = c.nano_faded_color }
          end,
          fmt = show_tab_indicator,
        },
      },

      lualine_z = {},
    },

    inactive_winbar = {
      lualine_a = {
        {
          "inactive_mode",
          fmt = function()
            return "   "
          end
        }
      },

      lualine_b = {
        { "filetype", color = { gui = "bold" } },
        { "filename" },
      },

      lualine_c = {
        {
          "branch",
          color = function ()
            local c = require("nano-theme.colors").get()
            return { fg = c.nano_faded_color }
          end
        }
      },

      lualine_x = {},

      lualine_y = {},

      lualine_z = {},
    },
  },
}
