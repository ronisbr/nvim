-- Description -----------------------------------------------------------------------------
--
-- Statusline configuration.
--
--------------------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------------------
--                                    Local Variables                                     --
--------------------------------------------------------------------------------------------

-- Table used to obtain the current mode and color.
local ctrl_S = vim.api.nvim_replace_termcodes("<C-S>", true, true, true)
local ctrl_V = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)

local modes = setmetatable(
  {
    ["n"]    = { long = "Normal",   short = " N ", hl = "StatuslineModeNormal" },
    ["nt"]   = { long = "Normal",   short = " N ", hl = "StatuslineModeNormal" },
    ["v"]    = { long = "Visual",   short = " V ", hl = "StatuslineModeVisual" },
    ["V"]    = { long = "V-Line",   short = "V/L", hl = "StatuslineModeVisual" },
    [ctrl_V] = { long = "V-Block",  short = "V/B", hl = "StatuslineModeVisual" },
    ["s"]    = { long = "Select",   short = " S ", hl = "StatuslineModeVisual" },
    ["S"]    = { long = "S-Line",   short = "S/L", hl = "StatuslineModeVisual" },
    [ctrl_S] = { long = "S-Block",  short = "S/B", hl = "StatuslineModeVisual" },
    ["i"]    = { long = "Insert",   short = " I ", hl = "StatuslineModeInsert" },
    ["ic"]   = { long = "Insert",   short = " I ", hl = "StatuslineModeInsert" },
    ["R"]    = { long = "Replace",  short = " R ", hl = "StatuslineModeReplace" },
    ["c"]    = { long = "Command",  short = " C ", hl = "StatuslineModeNormal" },
    ["r"]    = { long = "Prompt",   short = " P ", hl = "StatuslineModeNormal" },
    ["!"]    = { long = "Shell",    short = "Shl", hl = "StatuslineModeNormal" },
    ["t"]    = { long = "Terminal", short = " T ", hl = "StatuslineModeNormal" },
  },
  {
    __index = function()
      return   { long = "Unknown",  short = " U ", hl = "StatuslineModeNormal" }
    end,
  }
)

-- List of filetypes that will be excluded from setting a statusline.
local excluded_filetypes = {
  "snacks_dashboard",
  "ministarter"
}

--------------------------------------------------------------------------------------------
--                                   Private Functions                                    --
--------------------------------------------------------------------------------------------

-- Return a string with the names of the active LSP clients for the buffer `bufnr`.
local function active_lsp_clients(bufnr)
  local buf_ft = vim.bo[bufnr].filetype
  local names  = {}

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if vim.list_contains(client.config.filetypes or {}, buf_ft) then
      table.insert(names, client.name)
    end
  end

  return table.concat(names, ", ")
end

local get_color = require("misc.util").get_color

-- Configure the highlight groups used by the statusline.
local function configure_hl_groups()
  local statusline_bg = get_color("Statusline", "bg") or get_color("Visual", "bg")

  vim.api.nvim_set_hl(
    0,
    "StatuslineDefault",
    {
      fg = get_color("Statusline", "fg"),
      bg = statusline_bg,
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslineDefaultBold",
    {
      fg   = get_color("Statusline", "fg"),
      bg   = statusline_bg,
      bold = true,
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslineFaded",
    {
      fg = get_color("Dimmed", "fg") or get_color("Comment", "fg"),
      bg = statusline_bg
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslinePopout",
    {
      fg = get_color("WarningMsg", "fg"),
      bg = statusline_bg
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslineSalient",
    {
      fg = get_color("Special", "fg"),
      bg = statusline_bg
    }
  )

  -- Diagnostics ---------------------------------------------------------------------------

  for _, severity in ipairs({ "Error", "Warn", "Info", "Hint" }) do
    vim.api.nvim_set_hl(
      0,
      "StatuslineDiagnostic" .. severity,
      {
        fg = get_color("Diagnostic" .. severity, "fg"),
        bg = statusline_bg,
      }
    )
  end

  -- Neovim Modes --------------------------------------------------------------------------

  local statusline_default_bg = get_color("StatuslineDefault", "bg")
  local mode_fg = statusline_default_bg
    or (vim.o.background == "dark" and "#000000" or "#ffffff")

  vim.api.nvim_set_hl(
    0,
    "StatuslineModeNormal",
    {
      fg = mode_fg,
      bg = get_color("StatuslineDefault", "fg"),
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslineModeInsert",
    {
      fg = mode_fg,
      bg = get_color("WarningMsg", "fg"),
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslineModeReplace",
    {
      fg = mode_fg,
      bg = get_color("ErrorMsg", "fg"),
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslineModeVisual",
    {
      fg = mode_fg,
      bg = get_color("Special", "fg"),
    }
  )

  -- Folder Block --------------------------------------------------------------------------

  local folder_bg = get_color("NonText", "fg")

  vim.api.nvim_set_hl(
    0,
    "StatuslineFolder",
    {
      fg = get_color("Normal", "fg"),
      bg = folder_bg,
      bold = true,
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslineFolderCap",
    {
      fg = folder_bg,
      bg = statusline_bg,
    }
  )

  -- Mode separators (for the slant on the right side of the mode indicator).
  for _, hl_name in ipairs({
    "StatuslineModeNormal",
    "StatuslineModeInsert",
    "StatuslineModeReplace",
    "StatuslineModeVisual",
  }) do
    vim.api.nvim_set_hl(
      0,
      hl_name .. "Cap",
      {
        fg = get_color(hl_name, "bg"),
        bg = folder_bg,
      }
    )
  end

  -- Multicursor Badge ---------------------------------------------------------------------

  vim.api.nvim_set_hl(
    0,
    "StatuslineMulticursor",
    {
      fg   = mode_fg,
      bg   = get_color("Special", "fg"),
      bold = true,
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslineMulticursorFollow",
    {
      fg   = mode_fg,
      bg   = get_color("WarningMsg", "fg"),
      bold = true,
    }
  )

  -- Round caps for the pill-shaped badge.
  for _, hl_name in ipairs({ "StatuslineMulticursor", "StatuslineMulticursorFollow" }) do
    vim.api.nvim_set_hl(
      0,
      hl_name .. "Cap",
      {
        fg = get_color(hl_name, "bg"),
        bg = statusline_bg,
      }
    )
  end
end

-- Statusline Components -----------------------------------------------------------------------

-- Center a string within a given width by padding with spaces.
local function center_string(str, width)
  local len   = #str
  local left  = math.floor((width - len) / 2)
  local right = width - len - left
  return string.rep(" ", left) .. str .. string.rep(" ", right)
end

-- Width of the mode name area (based on the longest mode name: "Terminal").
local mode_name_width = 8

-- Powerline slant separator for the right edge (U+E0BC gives a / shape).
local mode_sep_r = "\238\130\188"

-- Powerline round caps (U+E0B6 and U+E0B4) for pill-shaped badges.
local pill_cap_l = "\238\130\182"
local pill_cap_r = "\238\130\180"

-- Icons for the multicursor badge: nf-fa-i_cursor (U+F246) and nf-fa-link (U+F0C1), the
-- latter indicating that the follow mode is enabled.
local multicursor_icon = "\239\137\134"
local follow_icon      = "\239\131\129"

-- Current Neovim mode.
local function statusline__mode()
  local mode      = vim.api.nvim_get_mode().mode
  local mode_info = modes[mode] or modes["n"]
  local mode_str  = (mode_info.long):upper()
  local cap_hl    = mode_info.hl .. "Cap"

  return
    "%#" .. mode_info.hl .. "# " .. center_string(mode_str, mode_name_width) .. " " ..
    "%#" .. cap_hl .. "#" .. mode_sep_r
end

-- Space between components.
local function statusline__space()
  return "%#StatuslineDefault# "
end

-- File name.
local function statusline__filename()
  local is_buffer_modified = vim.bo.modified
  local modified_str = ""

  if is_buffer_modified then
    modified_str = "[+] "
  end

  return "%#StatuslineDefaultBold#" .. modified_str .. "%t"
end

-- Current folder.
local function statusline__folder()
  local folder = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  return
    "%#StatuslineFolder#   " .. folder .. " " ..
    "%#StatuslineFolderCap#" .. mode_sep_r
end

-- File type.
local function statusline__filetype()
  local filetype = vim.bo.filetype

  if filetype == "" then
    return ""
  end

  local fileicon = ""
  local summary  = vim.b.minigit_summary
  local branch   = summary and summary.head_name or ""

  if _G.MiniIcons ~= nil and type(_G.MiniIcons.get) == "function" then
    fileicon = _G.MiniIcons.get("filetype", filetype) .. " "
  end

  if branch ~= "" then
    branch = ", %#StatuslineFaded##" .. vim.fn.escape(branch, "%#") .. "%#StatuslineDefault#"
  end

  return string.format("%%#StatuslineDefault#(%s%s%s)", fileicon, filetype, branch)
end

-- Active LSP servers.
local function statusline__lsp_clients()
  local clients = active_lsp_clients(0)

  if clients == "" then
    return ""
  end

  return "%#StatuslineFaded#[ " .. clients .. "]"
end

-- Diagnostic severities shown in the statusline: severity, icon (nf-fa-times_circle,
-- nf-fa-exclamation_triangle, nf-fa-info_circle, and nf-fa-lightbulb_o), and highlight group.
local diagnostic_severities = {
  { vim.diagnostic.severity.ERROR, vim.fn.nr2char(0xF057), "StatuslineDiagnosticError" },
  { vim.diagnostic.severity.WARN,  vim.fn.nr2char(0xF071), "StatuslineDiagnosticWarn"  },
  { vim.diagnostic.severity.INFO,  vim.fn.nr2char(0xF05A), "StatuslineDiagnosticInfo"  },
  { vim.diagnostic.severity.HINT,  vim.fn.nr2char(0xF0EB), "StatuslineDiagnosticHint"  },
}

-- Number of diagnostics per severity.
local function statusline__diagnostics()
  local counts = vim.diagnostic.count(0)
  local parts  = {}

  for _, severity in ipairs(diagnostic_severities) do
    local count = counts[severity[1]]

    if count and count > 0 then
      table.insert(parts, "%#" .. severity[3] .. "#" .. severity[2] .. " " .. count)
    end
  end

  if #parts == 0 then
    return ""
  end

  return " " .. table.concat(parts, " ")
end

-- Tabs.
local function statusline__tabs()
  local tabs = vim.api.nvim_list_tabpages()

  if #tabs <= 1 then
    return ""
  end

  local current   = vim.api.nvim_get_current_tabpage()
  local tab_parts = {}

  for i, tab in ipairs(tabs) do
    if (tab == current) then
      table.insert(tab_parts, "%#StatuslineDefault#" .. tostring(i) .. "%#StatuslineFaded#")
    else
      table.insert(tab_parts, tostring(i))
    end
  end

  return " %#StatuslineFaded#[" .. table.concat(tab_parts, " | ") .. "]"
end

-- Cursor position.
local function statusline__cursor_position()
  return "%#StatuslineFaded# %4v:%-5l (%P)"
end

-- Return a string with the current macro being recorded or an empty string if we are not
-- recording a macro.
local function statusline__macro_recording()
  local reg_recording = vim.fn.reg_recording()

  if reg_recording == "" then
    return ""
  end

  return "%#StatuslinePopout#󰑊 " .. reg_recording .. " "
end

-- Display the visual selection information (number of selected lines and columns).
local function statusline__visual_selection_information()
  local mode = vim.api.nvim_get_mode().mode

  local is_visual_mode       = mode:find("[Vv]")
  local is_visual_block_mode = mode:find("[\22]")

  -- We only need to evaluate this function if we are in a visual mode.
  if not is_visual_mode and not is_visual_block_mode then
    return ""
  end

  -- Get the position of the initial visual mode selection.
  local vpos = vim.fn.getpos("v")
  local begin_pos = {
    row = vpos[2],
    col = vpos[3] - 1
  }

  -- Get the position of the cursor.
  local cursor = vim.api.nvim_win_get_cursor(0)
  local end_pos = {
    row = cursor[1],
    col = cursor[2]
  }

  -- Compute the number of lines and columns between the beginning and end positions.
  local lines   = math.abs(end_pos.row - begin_pos.row) + 1
  local columns = math.abs(end_pos.col - begin_pos.col) + 1

  -- Assemble the text and return.
  if is_visual_mode then
    return "%#StatuslineSalient#[" .. tostring(lines) .. "L]"
  end

  -- If we reach this point, we are in a visual block mode.
  return "%#StatuslineSalient#[" .. tostring(lines) .. "L " .. tostring(columns) .. "C]"
end

-- Native multicursor indicator (`:h multicursor`): a pill badge with the number of extra
-- cursors. When the follow mode (`q=`) is enabled, the badge changes color and shows a link
-- icon. The state is tracked by `misc.multicursor`.
local function statusline__multicursor()
  local mc    = require("misc.multicursor")
  local count = mc.cursors()

  if count == 0 then
    return ""
  end

  local hl   = mc.follow and "StatuslineMulticursorFollow" or "StatuslineMulticursor"
  local text = multicursor_icon .. " " .. tostring(count)

  if mc.follow then
    text = text .. " " .. follow_icon
  end

  return
    "%#" .. hl .. "Cap#" .. pill_cap_l ..
    "%#" .. hl .. "#" .. text ..
    "%#" .. hl .. "Cap#" .. pill_cap_r ..
    statusline__space()
end

-- Render Functions ------------------------------------------------------------------------

-- Default render function.
local function statusline__render_default()
  local statusline_components = {
    statusline__mode(),
    statusline__folder(),
    statusline__space(),
    statusline__macro_recording(),
    statusline__filename(),
    statusline__space(),
    statusline__filetype(),
    statusline__space(),
    statusline__lsp_clients(),
    statusline__diagnostics(),
    "%#StatuslineDefault#%=",
    statusline__multicursor(),
    statusline__visual_selection_information(),
    statusline__space(),
    statusline__cursor_position(),
    statusline__tabs(),
  }

  return table.concat(statusline_components, "")
end

-- Render function for read-only buffers.
local function statusline__render_read_only_buffer()
  return "%#StatuslineDefault#%h%q %f"
end

-- Render function for quickfix buffers.
local function statusline__render_quickfix()
  local fileicon       = ""
  local quickfix_title = vim.w.quickfix_title

  if _G.MiniIcons ~= nil and type(_G.MiniIcons.get) == "function" then
    fileicon = _G.MiniIcons.get("filetype", "qf") .. "  "
  end

  return
    "%#StatuslineDefault#" ..
    fileicon ..
    "%q " ..
    "%#StatuslineSalient#" ..
    quickfix_title ..
    "%=" ..
    "%#StatuslineFaded#%l / %L (%p %%)"
end

--------------------------------------------------------------------------------------------
--                                    Public Functions                                    --
--------------------------------------------------------------------------------------------

-- Render the statusline.
function M.render()
  if vim.list_contains(excluded_filetypes, vim.bo.filetype) then
    return ""
  end

  if vim.bo.buftype == "quickfix" then
    return statusline__render_quickfix()
  end

  if vim.bo.readonly then
    return statusline__render_read_only_buffer()
  end

  return statusline__render_default()
end

-- Setup the statusline.
function M.setup()
  configure_hl_groups()
  vim.opt.laststatus = 3
  vim.opt.showtabline = 0

  vim.go.statusline = "%{%v:lua.require('misc.statusline').render()%}"

  -- Create an autocmd to setup the statusline when the colorscheme is changed.
  vim.api.nvim_create_autocmd(
    "ColorScheme",
    {
      pattern = "*",
      callback = function()
        configure_hl_groups()
      end,
    }
  )

  -- Redraw the statusline when an LSP client is attached or detached, or when the
  -- diagnostics change.
  vim.api.nvim_create_autocmd(
    {
      "DiagnosticChanged",
      "LspAttach",
      "LspDetach",
    },
    {
      pattern = "*",
      callback = function()
        vim.cmd.redrawstatus()
      end,
    }
  )
end

return M
