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
  local buf_ft       = vim.bo[bufnr].filetype
  local clients      = vim.lsp.get_clients({ bufnr = bufnr })
  local client_names = {}

  if next(clients) == nil then
    return ""
  end

  for _, client in ipairs(clients) do
    local filetypes = client.config and client.config.filetypes

    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
      table.insert(client_names, client.name)
    end
  end

  return table.concat(client_names, ", ")
end

-- Return the color of the attribute `attr` of the highlight group `hl_group`.
local function get_color(hl_group, attribute)
  local hl = vim.api.nvim_get_hl(0, { name = hl_group })

  if hl[attribute] then
    return "#" .. string.format("%06x", hl[attribute])
  end

  return nil
end

-- Return the current git branch name, or an empty string if the current directory is not a
-- git repository. Notice that we will cache the result for 10 seconds considering the file
-- path to avoid unnecessary calls to the `git` command, which can lock the UI.
local branch_cache = {}

local function git_branch()
  local filename = vim.api.nvim_buf_get_name(0)

  if filename == "" then
    return ""
  end

  -- Check if the timestamp of the cache is still valid (10 s).
  local cache = branch_cache[filename]
  local now   = vim.uv.now()

  if cache and (now - cache.time < 10000) then
    return cache.branch
  end

  -- We must run the git command in the directory of the file because the statusline can be
  -- rendered before changing the directory.
  local branch = vim.fn.system(
    "git -C " ..
    vim.fn.fnamemodify(filename, ':p:h') ..
    " branch --show-current 2>/dev/null | tr -d '\n'"
  )

  branch_cache[filename] = {
    branch = branch,
    time   = now
  }

  return branch
end

-- Configure the highlight groups used by the statusline.
local function configure_hl_groups()
  local statusline_bg = get_color("Statusline", "bg")

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
      fg = get_color("Comment", "fg"),
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

  -- Neovim Modes --------------------------------------------------------------------------

  local statusline_default_bg = get_color("StatuslineDefault", "bg")

  vim.api.nvim_set_hl(
    0,
    "StatuslineModeNormal",
    {
      fg = statusline_default_bg,
      bg = get_color("StatuslineDefault", "fg"),
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslineModeInsert",
    {
      fg = statusline_default_bg,
      bg = get_color("WarningMsg", "fg"),
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslineModeReplace",
    {
      fg = statusline_default_bg,
      bg = get_color("ErrorMsg", "fg"),
    }
  )

  vim.api.nvim_set_hl(
    0,
    "StatuslineModeVisual",
    {
      fg = statusline_default_bg,
      bg = get_color("Special", "fg"),
    }
  )
end

-- Statusline Components -----------------------------------------------------------------------

-- Current Neovim mode.
local function statusline__mode()
  local mode      = vim.api.nvim_get_mode().mode
  local mode_info = modes[mode] or modes["n"]

  return string.format("%%#%s# %s ", mode_info.hl, mode_info.short)
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

-- File type.
local function statusline__filetype()
  local filetype = vim.bo.filetype

  if filetype == "" then
    return ""
  end

  local fileicon = ""
  local branch   = git_branch()

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

  return "%#StatuslineFaded#[" .. clients .. "]"
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

  return "%#StatuslineFaded#[" .. table.concat(tab_parts, " | ") .. "]"
end

-- Cursor position.
local function statusline__cursor_position()
  return "%#StatuslineFaded# %v:%l (%P)"
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

-- Render Functions ------------------------------------------------------------------------

-- Default render function when the buffer is active.
local function statusline__render_active()
  local statusline_components = {
    statusline__mode(),
    statusline__space(),
    statusline__macro_recording(),
    statusline__filename(),
    statusline__space(),
    statusline__filetype(),
    statusline__space(),
    statusline__lsp_clients(),
    "%#StatuslineDefault#%=",
    statusline__visual_selection_information(),
    statusline__space(),
    statusline__tabs(),
    statusline__space(),
    statusline__cursor_position(),
  }

  return table.concat(statusline_components, "")
end

-- Default render function when the buffer is inactive.
local function statusline__render_inactive()
  return "%#StatuslineDefault#      %#StatuslineFaded#%t"
end

-- Render function for read-only buffers when the buffer is active.
local function statusline__render_read_only_buffer_active()
  return "%#StatuslineDefault#%h%q %f"
end

-- Render function for read-only buffers when the buffer is inactive.
local function statusline__render_read_only_buffer_inactive()
  return "%#StatuslineFaded#%h%q %f"
end

-- Render function for quickfix buffers when the buffer is active.
local function statusline__render_quickfix_active()
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

-- Render function for quickfix buffers when the buffer is inactive.
local function statusline__render_quickfix_inactive()
  local fileicon       = ""
  local quickfix_title = vim.w.quickfix_title

  if _G.MiniIcons ~= nil and type(_G.MiniIcons.get) == "function" then
    fileicon = _G.MiniIcons.get("filetype", "qf") .. "  "
  end

  return
    "%#StatuslineFaded#" ..
    fileicon ..
    "[Quickfix List] " ..
    quickfix_title
end

--------------------------------------------------------------------------------------------
--                                    Public Functions                                    --
--------------------------------------------------------------------------------------------

-- Render the statusline.
function M.render(active)
  -- Check if the current filetype must be excluded.
  local filetype    = vim.bo.filetype
  local is_excluded = false

  for i = 1, #excluded_filetypes do
    if filetype == excluded_filetypes[i] then
      is_excluded = true
      break
    end
  end

  if is_excluded then
    return ""
  end

  -- Check if the current buffer is a quickfix buffer.
  if vim.bo.buftype == "quickfix" then
    return active == 0 and
      statusline__render_quickfix_inactive() or
      statusline__render_quickfix_active()
  end

  -- Check if the current buffer is read-only.
  local is_read_only = vim.bo.readonly

  if is_read_only then
    return active == 0 and
      statusline__render_read_only_buffer_inactive() or
      statusline__render_read_only_buffer_active()
  end

  -- Render the normal statusline.
  return active == 0 and
    statusline__render_inactive() or
    statusline__render_active()
end

-- Setup the statusline.
function M.setup()
  configure_hl_groups()
  vim.opt.laststatus = 3
  vim.opt.showtabline = 0

  vim.go.statusline =
    "%{" ..
      "%(nvim_get_current_win()==#g:actual_curwin) ? " ..
        "v:lua.require('misc.statusline').render(1) : " ..
        "v:lua.require('misc.statusline').render(0) " ..
    "%}"

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

  -- Redraw the statusline when an LSP client is attached or detached.
  vim.api.nvim_create_autocmd(
    {
      "LspAttach",
      "LspDetach"
    },
    {
      pattern = "*",
      callback = function()
        -- We need to redraw the statusline because the LSP clients may have changed.
        vim.cmd("redrawstatus")
      end,
    }
  )
end

return M

-- vim:ts=2:sts=2:sw=2:et
