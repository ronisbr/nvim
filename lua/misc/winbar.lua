-- Description -----------------------------------------------------------------------------
--
-- Winbar configuration.
--
--------------------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------------------
--                                    Local Variables                                     --
--------------------------------------------------------------------------------------------

-- Table with used to obtain the current mode and color.
local ctrl_s = vim.api.nvim_replace_termcodes("<C-S>", true, true, true)
local ctrl_v = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)

local modes = setmetatable(
  {
    ["n"]    = { long = "Normal",   short = " N ", hl = "WinbarModeNormal" },
    ["v"]    = { long = "Visual",   short = " V ", hl = "WinbarModeVisual" },
    ["V"]    = { long = "V-Line",   short = "V/L", hl = "WinbarModeVisual" },
    [ctrl_v] = { long = "V-Block",  short = "V/B", hl = "WinbarModeVisual" },
    ["s"]    = { long = "Select",   short = " S ", hl = "WinbarModeVisual" },
    ["S"]    = { long = "S-Line",   short = "S/L", hl = "WinbarModeVisual" },
    [ctrl_s] = { long = "S-Block",  short = "S/B", hl = "WinbarModeVisual" },
    ["i"]    = { long = "Insert",   short = " I ", hl = "WinbarModeInsert" },
    ["ic"]   = { long = "Insert",   short = " I ", hl = "WinbarModeInsert" },
    ["R"]    = { long = "Replace",  short = " R ", hl = "WinbarModeReplace" },
    ["c"]    = { long = "Command",  short = " C ", hl = "WinbarModeNormal" },
    ["r"]    = { long = "Prompt",   short = " P ", hl = "WinbarModeNormal" },
    ["!"]    = { long = "Shell",    short = "Shl", hl = "WinbarModeNormal" },
    ["t"]    = { long = "Terminal", short = " T ", hl = "WinbarModeNormal" },
  },
  {
    __index = function()
      return   { long = "Unknown",  short = " U ", hl = "WinbarModelNormal" }
    end,
  }
)

-- List of filetypes that will be excluded from setting a winbar.
local excluded_filetypes = {
  "snacks_dashboard",
}

--------------------------------------------------------------------------------------------
--                                   Private Functions                                    --
--------------------------------------------------------------------------------------------

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

  -- We must run the git command in the directory of the file because the winbar can be
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

function M.branch() return branch_cache end

-- Configure the highlight groups used by the winbar.
local function configure_hl_groups()
  local statusline_bg = get_color("Statusline", "bg")

  vim.api.nvim_set_hl(
    0,
    "WinbarDefault",
    {
      fg = get_color("Statusline", "fg"),
      bg = statusline_bg
    }
  )

  vim.api.nvim_set_hl(
    0,
    "WinbarFaded",
    {
      fg = get_color("Comment", "fg"),
      bg = statusline_bg
    }
  )

  vim.api.nvim_set_hl(
    0,
    "WinbarPopout",
    {
      fg = get_color("WarningMsg", "fg"),
      bg = statusline_bg
    }
  )

  vim.api.nvim_set_hl(
    0,
    "WinbarSalient",
    {
      fg = get_color("Special", "fg"),
      bg = statusline_bg
    }
  )

  -- Neovim Modes --------------------------------------------------------------------------

  local winbar_default_bg = get_color("WinbarDefault", "bg")

  vim.api.nvim_set_hl(
    0,
    "WinbarModeNormal",
    {
      fg = winbar_default_bg,
      bg = get_color("WinbarDefault", "fg"),
    }
  )

  vim.api.nvim_set_hl(
    0,
    "WinbarModeInsert",
    {
      fg = winbar_default_bg,
      bg = get_color("WarningMsg", "fg"),
    }
  )

  vim.api.nvim_set_hl(
    0,
    "WinbarModeReplace",
    {
      fg = winbar_default_bg,
      bg = get_color("ErrorMsg", "fg"),
    }
  )

  vim.api.nvim_set_hl(
    0,
    "WinbarModeVisual",
    {
      fg = winbar_default_bg,
      bg = get_color("Special", "fg"),
    }
  )
end

-- Winbar Components -----------------------------------------------------------------------

-- Current Neovim mode.
local function winbar__mode()
  local mode      = vim.api.nvim_get_mode().mode
  local mode_info = modes[mode] or modes["n"]

  return string.format("%%#%s# %s ", mode_info.hl, mode_info.short)
end

-- Space between components.
local function winbar__space()
  return "%#WinbarDefault# "
end

-- File name.
local function winbar__filename()
  local is_buffer_modified = vim.api.nvim_get_option_value("modified", {})
  local modified_str = ""

  if is_buffer_modified then
    modified_str = "[+] "
  end

  return "%#WinbarDefault#" .. modified_str .. "%t"
end

-- File type.
local function winbar__filetype()
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
    branch = ", %#WinbarFaded##" .. branch .. "%#WinbarDefault#"
  end

  return string.format("%%#WinbarDefault#(%s%s%s)", fileicon, filetype, branch)
end

-- Cursor position.
local function winbar__cursor_position()
  return "%#WinbarFaded# %v:%l (%P)"
end

-- Return a string with the current macro being recorded or an empty string if we are not
-- recording a macro.
local function winbar__macro_recording()
  local reg_recording = vim.fn.reg_recording()

  if reg_recording == "" then
    return ""
  end

  return "%#WinbarPopout#󰑊 " .. reg_recording .. " "
end

-- Display the visual selection information (number of selected lines and columns).
local function winbar__visual_selection_information()
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
    return "%#WinbarSalient#[" .. tostring(lines) .. "L]"
  end

  -- If we reach this point, we are in a visual block mode.
  return "%#WinbarSalient#[" .. tostring(lines) .. "L " .. tostring(columns) .. "C]"
end

-- Render Functions ------------------------------------------------------------------------

-- Default render function when the buffer is active.
local function winbar__render_active()
  local winbar_components = {
    winbar__mode(),
    winbar__space(),
    winbar__macro_recording(),
    winbar__filename(),
    winbar__space(),
    winbar__filetype(),
    "%#WinbarDefault#%=",
    winbar__visual_selection_information(),
    winbar__space(),
    winbar__cursor_position(),
  }

  return table.concat(winbar_components, "")
end

-- Default render function when the buffer is inactive.
local function winbar__render_inactive()
  return "%#WinbarDefault#      %#WinbarFaded#%t"
end

-- Render function for read-only buffers when the buffer is active.
local function winbar__render_read_only_buffer_active()
  return "%#WinbarDefault#%h%q %f"
end

-- Render function for read-only buffers when the buffer is inactive.
local function winbar__render_read_only_buffer_inactive()
  return "%#WinbarFaded#%h%q %f"
end

-- Render function for quickfix buffers when the buffer is active.
local function winbar__render_quickfix_active()
  local fileicon       = ""
  local quickfix_title = vim.w.quickfix_title

  if _G.MiniIcons ~= nil and type(_G.MiniIcons.get) == "function" then
    fileicon = _G.MiniIcons.get("filetype", "qf") .. "  "
  end

  return
    "%#WinbarDefault#" ..
    fileicon ..
    "%q " ..
    "%#WinbarSalient#" ..
    quickfix_title ..
    "%=" ..
    "%#WinbarFaded#%l / %L (%p %%)"
end

-- Render function for quickfix buffers when the buffer is inactive.
local function winbar__render_quickfix_inactive()
  local fileicon       = ""
  local quickfix_title = vim.w.quickfix_title

  if _G.MiniIcons ~= nil and type(_G.MiniIcons.get) == "function" then
    fileicon = _G.MiniIcons.get("filetype", "qf") .. "  "
  end

  return
    "%#WinbarFaded#" ..
    fileicon ..
    "[Quickfix List] " ..
    quickfix_title
end

--------------------------------------------------------------------------------------------
--                                    Public Functions                                    --
--------------------------------------------------------------------------------------------

-- Render the winbar.
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
    if active == 0 then
      return winbar__render_quickfix_inactive()
    end

    return winbar__render_quickfix_active()
  end

  -- Check if the current buffer is read-only.
  local is_read_only = vim.api.nvim_get_option_value("readonly", {})

  if is_read_only then
    if active == 0 then
      return winbar__render_read_only_buffer_inactive()
    end

    return winbar__render_read_only_buffer_active()
  end

  -- Render the normal winbar.
  if active == 0 then
    return winbar__render_inactive()
  end

  return winbar__render_active()
end

-- Setup the winbar.
function M.setup()
  configure_hl_groups()
  vim.opt.laststatus = 0
  vim.go.winbar =
    "%{" ..
      "%(nvim_get_current_win()==#g:actual_curwin || &laststatus==3) ? " ..
        "v:lua.require(\"misc.winbar\").render(1) : " ..
        "v:lua.require(\"misc.winbar\").render(0) " ..
    "%}"

  -- Create an autocmd to setup the winbar when the coloscheme is changed.
  vim.api.nvim_create_autocmd(
    "ColorScheme",
    {
      pattern = "*",
      callback = function()
        require("misc.winbar").setup()
      end,
    }
  )
end

return M

-- vim:ts=2:sts=2:sw=2:et
