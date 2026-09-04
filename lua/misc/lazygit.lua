-- Description -----------------------------------------------------------------------------
--
-- Open lazygit in a floating window.
--
-- This file was heavily inspired in the Snacks.nvim function to open LazyGit.
--
-- -----------------------------------------------------------------------------------------

local util  = require("misc.util")
local float = require("misc.float")

local M = {}

--------------------------------------------------------------------------------------------
--                                    Local Variables                                     --
--------------------------------------------------------------------------------------------

local theme_path  = vim.fn.stdpath("cache") .. "/lazygit-theme.yml"
local config_path = vim.fn.stdpath("cache") .. "/lazygit-config.yml"

--------------------------------------------------------------------------------------------
--                                    Local Functions                                     --
--------------------------------------------------------------------------------------------

--- Build the list of color attributes for a lazygit theme entry.
---
--- @param entry table Table with the optional fields `fg` and `bg` (highlight group names)
---   and `bold` (boolean).
--- @return table List of color strings (e.g., `{ "#ffffff", "bold" }`).
local function build_color(entry)
  local colors = {}

  local fg = entry.fg and util.get_color(entry.fg, "fg")
  local bg = entry.bg and util.get_color(entry.bg, "bg")

  if fg then
    table.insert(colors, fg)
  end

  if bg then
    table.insert(colors, bg)
  end

  if entry.bold then
    table.insert(colors, "bold")
  end

  return colors
end

--- Write the lazygit configuration file.
local function update_lazygit_config()
  vim.fn.writefile(
    {
      "os:",
      "  editPreset: nvim-remote",
      "git:",
      "  parseEmoji: true",
      "gui:",
      "  nerdFontsVersion: '3'",
    },
    config_path
  )
end

--- Write the lazygit theme file based on the Neovim highlight groups.
local function update_lazygit_theme()
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

  local yaml = { "gui:", "  theme:" }

  for key, spec in pairs(theme) do
    local colors = build_color(spec)
    local value  = #colors > 0 and ('["' .. table.concat(colors, '", "') .. '"]') or "[]"

    table.insert(yaml, string.format("    %s: %s", key, value))
  end

  vim.fn.writefile(yaml, theme_path)
end

--- Open lazygit in a floating window.
---
--- @param args string|nil Arguments appended to the lazygit command (e.g. `"log"`).
local function open_lazygit(args)
  local cmd = string.format(
    'lazygit --use-config-file="%s,%s"%s',
    config_path,
    theme_path,
    args and (" " .. args) or ""
  )

  local width, height, row, col = float.centered(0.8, 0.8)
  local buf = vim.api.nvim_create_buf(false, true)
  local f   = float.open({ buf = buf, width = width, height = height, row = row, col = col })

  vim.fn.jobstart(
    cmd,
    {
      term    = true,
      on_exit = function()
        vim.schedule(function() float.close(f) end)
      end,
    }
  )

  vim.cmd.startinsert()
end

--------------------------------------------------------------------------------------------
--                                    Public Functions                                    --
--------------------------------------------------------------------------------------------

--- Setup the lazygit integration: theme, configuration, keymaps, and autocmds.
function M.setup()
  vim.fn.mkdir(vim.fn.stdpath("cache"), "p")

  update_lazygit_theme()
  update_lazygit_config()

  vim.api.nvim_create_user_command("LazyGit", function() open_lazygit() end, {})

  -- Keymaps -------------------------------------------------------------------------------

  vim.keymap.set("n", "<Leader>og", open_lazygit, { desc = "Open LazyGit", silent = true })

  vim.keymap.set(
    "n",
    "<Leader>ol",
    function() open_lazygit("log") end,
    { desc = "Open LazyGit Log", silent = true }
  )

  -- Autocmds ------------------------------------------------------------------------------

  vim.api.nvim_create_autocmd(
    "ColorScheme",
    {
      group    = vim.api.nvim_create_augroup("LazyGit", { clear = true }),
      callback = update_lazygit_theme,
    }
  )
end

return M
