-- Description -----------------------------------------------------------------------------
--
-- Open lazygit in a floating window.
--
-- This file was heavily inspired in the Snacks.nvim function to open LazyGit.
--
-- -----------------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------------------
--                                    Local Variables                                     --
--------------------------------------------------------------------------------------------

local util = require("misc.util")
local lazygit_theme_path = vim.fn.stdpath("cache") .. "/lazygit-theme.yml"
local lazygit_config_path = vim.fn.stdpath("cache") .. "/lazygit-config.yml"

-- Padding: 1 row top/bottom, 3 columns left/right.
local pad_v = 1
local pad_h = 3

-- Backdrop state.
local backdrop_buf = nil
local backdrop_win = nil

--------------------------------------------------------------------------------------------
--                                    Local Functions                                     --
--------------------------------------------------------------------------------------------

--- Build a list of color attributes for LazyGit theme entries.
-- @param entry table: Table containing optional 'fg', 'bg', and 'bold' fields.
--                    'fg' and 'bg' are highlight group names, 'bold' is a boolean.
-- @return table: List of color strings (e.g., {"#ffffff", "bold"}).
local function build_color(entry)
  local colors = {}

  if entry.fg then
    local fg = util.get_color(entry.fg, "fg")
    if fg then table.insert(colors, fg) end
  end

  if entry.bg then
    local bg = util.get_color(entry.bg, "bg")
    if bg then table.insert(colors, bg) end
  end

  if entry.bold then table.insert(colors, "bold") end

  return colors
end

--- Update the FloatingTermBg highlight group based on the current Normal background.
local function update_floating_term_bg()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local bg = normal.bg

  if not bg then return end

  local r = bit.rshift(bit.band(bg, 0xFF0000), 16)
  local g = bit.rshift(bit.band(bg, 0x00FF00), 8)
  local b = bit.band(bg, 0x0000FF)

  -- Determine if the theme is light or dark based on perceived luminance.
  local luminance = 0.299 * r + 0.587 * g + 0.114 * b
  local is_light = luminance >= 128

  local r_offset, g_offset, b_offset
  if is_light then
    -- Darker and warmer: reduce more aggressively, pull toward warm tones.
    r_offset = -4
    g_offset = -7
    b_offset = -10
  else
    r_offset = 15
    g_offset = 15
    b_offset = 15
  end

  r = math.max(0, math.min(255, r + r_offset))
  g = math.max(0, math.min(255, g + g_offset))
  b = math.max(0, math.min(255, b + b_offset))

  vim.api.nvim_set_hl(0, "FloatingTermBg", { bg = string.format("#%02x%02x%02x", r, g, b) })
end

--- Return the window options for the backdrop and the lazygit window.
-- @return table, table: Backdrop options and lazygit window options.
local function lazygit_window_opts()
  -- Notice that we are removing two lines to take into account the status line and command
  -- line.
  local ui     = vim.api.nvim_list_uis()[1]
  local width  = math.floor(ui.width * 0.8)
  local height = math.floor((ui.height - 2) * 0.8)
  local col    = math.floor((ui.width - width) / 2)
  local row    = math.floor(((ui.height - 2) - height) / 2)

  local backdrop_opts = {
    border    = "none",
    col       = col,
    height    = height,
    relative  = "editor",
    row       = row,
    style     = "minimal",
    width     = width,
    focusable = false,
    zindex    = 10,
  }

  local win_opts = {
    border   = "none",
    col      = col + pad_h,
    height   = height - 2 * pad_v,
    relative = "editor",
    row      = row + pad_v,
    style    = "minimal",
    width    = width - 2 * pad_h,
    zindex   = 11,
  }

  return backdrop_opts, win_opts
end

--- Open the backdrop window.
local function open_backdrop(opts)
  if not (backdrop_buf and vim.api.nvim_buf_is_valid(backdrop_buf)) then
    backdrop_buf = vim.api.nvim_create_buf(false, true)
  end

  backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, opts)
  vim.api.nvim_set_option_value("winhl", "Normal:FloatingTermBg", { win = backdrop_win })
end

--- Close the backdrop window.
local function close_backdrop()
  if backdrop_win and vim.api.nvim_win_is_valid(backdrop_win) then
    vim.api.nvim_win_close(backdrop_win, true)
    backdrop_win = nil
  end
end

--- Write the LazyGit config YAML file.
-- @param config_path string: Path to write the config YAML.
local function update_lazygit_config(config_path)
  local config_yaml = {
    "os:",
    "  editPreset: nvim-remote",
    "git:",
    "  parseEmoji: true",
    "gui:",
    "  nerdFontsVersion: '3'",
  }

  vim.fn.writefile(config_yaml, config_path)
end

--- Generate and write the LazyGit theme YAML file based on Neovim highlight groups.
-- @param theme_path string: Path to write the theme YAML.
local function update_lazygit_theme(theme_path)
  -- Set the theme for the LazyGit based on highlight groups.
  local theme = {
    [241]                      = { fg = "Special" },
    activeBorderColor          = { fg = "MatchParen", bold = true },
    cherryPickedCommitBgColor  = { fg = "Identifier" },
    cherryPickedCommitFgColor  = { fg = "Function" },
    defaultFgColor             = { fg = "Normal" },
    inactiveBorderColor        = { fg = "FloatBorder" },
    optionsTextColor           = { fg = "Function" },
    searchingActiveBorderColor = { fg = "MatchParen", bold = true },
    selectedLineBgColor        = { bg = "Visual" },
    unstagedChangesColor       = { fg = "DiagnosticError" },
  }

  -- Convert the table to YAML format.
  local yaml = { "gui:", "  theme:" }

  for key, spec in pairs(theme) do
    local colors = build_color(spec)

    local val
    if #colors > 0 then
      val = "[\"" .. table.concat(colors, "\", \"") .. "\"]"
    else
      val = "[]"
    end

    table.insert(yaml, string.format("    %s: %s", key, val))
  end

  -- Write the YAML to the theme file.
  vim.fn.writefile(yaml, theme_path)
end

--- Open a floating terminal window and run the given command.
-- @param cmd string: Command to run in the floating terminal.
local function open_lazygit_window(cmd)
  update_floating_term_bg()
  local backdrop_opts, win_opts = lazygit_window_opts()

  open_backdrop(backdrop_opts)

  local bufnr  = vim.api.nvim_create_buf(false, true)
  local win_id = vim.api.nvim_open_win(bufnr, true, win_opts)
  vim.api.nvim_set_option_value("winhl", "Normal:FloatingTermBg", { win = win_id })

  vim.fn.jobstart(
    cmd,
    {
      on_exit = function()
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win_id) then
            vim.api.nvim_win_close(win_id, true)
          end
          close_backdrop()
        end)
      end,
      term = true
    }
  )
  vim.cmd.startinsert()
end

--- Open LazyGit in a floating window with custom config and theme.
local function open_lazygit()
  local cmd = string.format(
    "lazygit --use-config-file=\"%s,%s\"",
    lazygit_config_path,
    lazygit_theme_path
  )
  open_lazygit_window(cmd)
end

--- Open LazyGit log view in a floating window with custom config and theme.
local function open_lazygit_log()
  local cmd = string.format(
    "lazygit --use-config-file=\"%s,%s\" log",
    lazygit_config_path,
    lazygit_theme_path
  )
  open_lazygit_window(cmd)
end

--------------------------------------------------------------------------------------------
--                                    Public Functions                                    --
--------------------------------------------------------------------------------------------

--- Setup function for the LazyGit integration.
-- Sets up theme/config, keymaps, and autocmds.
function M.setup()
  if vim.fn.isdirectory(vim.fn.stdpath("cache")) == 0 then
    vim.fn.mkdir(vim.fn.stdpath("cache"), "p")
  end

  update_lazygit_theme(lazygit_theme_path)
  update_lazygit_config(lazygit_config_path)

  vim.api.nvim_create_user_command("LazyGit", open_lazygit, {})

  -- Keymaps -------------------------------------------------------------------------------

  vim.keymap.set(
    "n",
    "<leader>og",
    open_lazygit,
    {
      desc    = "Open LazyGit",
      noremap = true,
      silent  = true
    }
  )

  vim.keymap.set(
    "n",
    "<leader>ol",
    open_lazygit_log,
    {
      desc    = "Open LazyGit Log",
      noremap = true,
      silent  = true
    }
  )

  -- Autocmds ------------------------------------------------------------------------------

  vim.api.nvim_create_augroup("LazyGit", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = "LazyGit",
    pattern = "*",
    callback = function() update_lazygit_theme(lazygit_theme_path) end,
  })
end

return M

