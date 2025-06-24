-- Description -----------------------------------------------------------------------------
--
-- Configuration of mini.nvim and its modules.
--
-- -----------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--                                    Local Functions                                     --
--------------------------------------------------------------------------------------------

-- mini.statusline -------------------------------------------------------------------------

-- Return the color of the attribute `attr` of the highlight group `hl_group`.
local function get_color(hl_group, attr)
  local hl = vim.api.nvim_get_hl(0, { name = hl_group })

  if hl[attr] then
    return "#" .. string.format("%06x", hl[attr])
  end

  return nil
end

-- Table with used to obtain the current mode and color.
local ctrl_s = vim.api.nvim_replace_termcodes("<C-S>", true, true, true)
local ctrl_v = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)

local modes = setmetatable(
  {
    ["n"]    = { long = "Normal",   short = " N ", hl = "MiniStatuslineModeNormal"  },
    ["v"]    = { long = "Visual",   short = " V ", hl = "MiniStatuslineModeVisual"  },
    ["V"]    = { long = "V-Line",   short = "VL ", hl = "MiniStatuslineModeVisual"  },
    [ctrl_v] = { long = "V-Block",  short = "VB ", hl = "MiniStatuslineModeVisual"  },
    ["s"]    = { long = "Select",   short = " S ", hl = "MiniStatuslineModeVisual"  },
    ["S"]    = { long = "S-Line",   short = "SL ", hl = "MiniStatuslineModeVisual"  },
    [ctrl_s] = { long = "S-Block",  short = "SB ", hl = "MiniStatuslineModeVisual"  },
    ["i"]    = { long = "Insert",   short = " I ", hl = "MiniStatuslineModeInsert"  },
    ["R"]    = { long = "Replace",  short = " R ", hl = "MiniStatuslineModeReplace" },
    ["c"]    = { long = "Command",  short = " C ", hl = "MiniStatuslineModeCommand" },
    ["r"]    = { long = "Prompt",   short = " P ", hl = "MiniStatuslineModeOther"   },
    ["!"]    = { long = "Shell",    short = "Sh ", hl = "MiniStatuslineModeOther"   },
    ["t"]    = { long = "Terminal", short = " T ", hl = "MiniStatuslineModeOther"   },
  },
  {
    __index = function()
      return   { long = "Unknown",  short = " U ", hl = "%#MiniStatuslineModeOther#" }
    end,
  }
)

-- We need to redraw the status line if a macro recording starts or end.
vim.api.nvim_create_autocmd("RecordingEnter", {
  pattern = "*",
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
  pattern = "*",
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

-- .. Functions to Provide Sections to the Status Line .....................................

-- Return the current branch name if we are in a git tree or an empty string otherwise.
local function ministatusline_branch_name()
  local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
  if branch ~= "" then
    return " " .. branch
  else
    return ""
  end
end

-- Return the file icon and type.
local function ministatusline_file_info()
  local filetype = vim.bo.filetype

  -- Don't show anything if no filetype or not inside a "normal buffer".
  if filetype == "" or vim.bo.buftype ~= "" then
    return ""
  end

  -- Add filetype icon.
  local has_devicons, devicons = pcall(require, "mini.icons")
  local icon = has_devicons and devicons.get("filetype", filetype) .. " " or ""

  return string.format("%s%s", icon, filetype)
end

local function ministatusline_file_encoding()
  return "[" .. (vim.bo.fileencoding or vim.bo.encoding) .. "]"
end

-- Show information regarding the current line location.
local function ministatusline_location()
  local line      = tostring(vim.api.nvim_win_get_cursor(0)[1])
  local lines     = tostring(vim.fn.line("$"))
  local line_info = string.rep(" ", lines:len() - line:len()) .. line .. "/" .. lines

  return " " .. line_info .. " 󰗧 %2v/%-2{virtcol(\"$\") - 1}"
end

-- Return a string with the current macro being recorded or an empty string if we are not
-- recording a macro.
local function ministatusline_macro_recording()
  if vim.fn.reg_recording() ~= "" then
    return "󰑊 " .. vim.fn.reg_recording()
  else
    return ""
  end
end

-- Return the current mode and the highlight to be used in the statusline.
local function ministatusline_modes(args)
  local mode_info = modes[vim.fn.mode()]
  local mode = mode_info.short
  return mode, mode_info.hl
end

-- Show the current search count.
local function ministatusline_search_count()
  if vim.v.hlsearch == 0 then
    return ""
  end

  local ok, s_count = pcall(vim.fn.searchcount, { recompute = true })

  if not ok or s_count.current == nil or s_count.total == 0 then
    return ""
  end

  if s_count.incomplete == 1 then
    return ' ?/?'
  else
    local too_many = ">" .. s_count.maxcount
    local current = s_count.current > s_count.maxcount and too_many or s_count.current
    local total = s_count.total > s_count.maxcount and too_many or s_count.total
    return " " .. current .. '/' .. total
  end
end

-- Return the visual selection information or empty string if we are not in a visual mode.
local function ministatusline_visual_selection_information()
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

--------------------------------------------------------------------------------------------
--                                  Plugin Configuration                                  --
--------------------------------------------------------------------------------------------

return {
  -- mini.align ----------------------------------------------------------------------------
  {
    "echasnovski/mini.align",
    event = "VeryLazy",
    version = false,

    opts = {}
  },

  -- mini.completion -----------------------------------------------------------------------

  {
    "echasnovski/mini.completion",
    lazy = false,
    version = false,
    dependencies = { "echasnovski/mini.snippets" },

    opts = { },

    config = function(_, opts)
      require("mini.completion").setup(opts)

      -- Disable completion in snacks inputs.
      -- For more informaiton, see:
      --   https://github.com/folke/snacks.nvim/issues/350#issuecomment-2677860901
      vim.api.nvim_create_autocmd(
        "FileType",
        {
          pattern = "snacks_picker_input",
          callback = function()
            vim.b.minicompletion_disable = true
          end
        }
      )
    end
  },

  -- mini.diff -----------------------------------------------------------------------------

  {
    "echasnovski/mini.diff",
    lazy = false,
    version = false,
    opts = { },
  },

  -- mini.hipatters ------------------------------------------------------------------------

  {
    "echasnovski/mini.hipatterns",
    lazy = false,
    version = false,

    config = function(_, opts)
      local hipatterns = require("mini.hipatterns")

      -- vim.api.nvim_set_hl(
      --   0,
      --   "MiniHipatternsFixme",
      --   {
      --     fg = get_color("Normal", "bg"),
      --     bg = get_color("Error", "fg")
      --   }
      -- )
      --
      -- vim.api.nvim_set_hl(
      --   0,
      --   "MiniHipatternsHack",
      --   {
      --     fg = get_color("Normal", "bg"),
      --     bg = get_color("Changed", "fg")
      --   }
      -- )
      --
      -- vim.api.nvim_set_hl(
      --   0,
      --   "MiniHipatternsTodo",
      --   {
      --     fg = get_color("Normal", "bg"),
      --     bg = get_color("Todo", "fg")
      --   }
      -- )
      --
      -- vim.api.nvim_set_hl(
      --   0,
      --   "MiniHipatternsNote",
      --   {
      --     fg = get_color("Normal", "bg"),
      --     bg = get_color("Comment", "fg")
      --   }
      -- )

      hipatterns.setup({
        highlighters = {
          fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
          hack  = { pattern = "%f[%w]()HACK()%f[%W]",  group = "MiniHipatternsHack"  },
          todo  = { pattern = "%f[%w]()TODO()%f[%W]",  group = "MiniHipatternsTodo"  },
          note  = { pattern = "%f[%w]()NOTE()%f[%W]",  group = "MiniHipatternsNote"  },

          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })
    end
  },

  -- mini.icons ----------------------------------------------------------------------------

  {
    "echasnovski/mini.icons",
    lazy = false,
    version = false,

    opts = { }
  },

  -- mini.misc -----------------------------------------------------------------------------

  {
    "echasnovski/mini.misc",
    lazy = false,
    version = false,

    opts = { },

    config = function(_, opts)
      local MiniMisc = require("mini.misc")

      require("mini.misc").setup(opts)

      MiniMisc.setup_auto_root(
        nil,
        function(path)
          return vim.fs.dirname(path)
        end
      )
      MiniMisc.setup_restore_cursor()
    end
  },

  -- mini.move -----------------------------------------------------------------------------

  {
    "echasnovski/mini.move",
    lazy = false,
    version = false,
    opts = { }
  },

  -- mini.snippets -------------------------------------------------------------------------

  {
    "echasnovski/mini.snippets",
    lazy = false,
    version = false,

    config = function()
      local gen_loader = require('mini.snippets').gen_loader

      require('mini.snippets').setup({
        snippets = {
          gen_loader.from_lang(),
        },
      })

      MiniSnippets.start_lsp_server()

      -- Keymaps ---------------------------------------------------------------------------

      local function mini_completion_map(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { noremap = true, expr = true })
      end

      -- Use <Tab> and <S-Tab> to navigate through completion items.
      mini_completion_map("i", "<Tab>",   "pumvisible() ? '<C-n>' : '<Tab>'")
      mini_completion_map("i", "<S-Tab>", "pumvisible() ? '<C-p>' : '<S-Tab>'")

      -- Configure a more consistent behavior of <CR>.
      local keys = {
        ["cr"]        = vim.api.nvim_replace_termcodes("<CR>",      true, true, true),
        ["ctrl-y"]    = vim.api.nvim_replace_termcodes("<C-y>",     true, true, true),
        ["ctrl-y_cr"] = vim.api.nvim_replace_termcodes("<C-y><CR>", true, true, true),
      }

      _G.cr_action = function()
        if vim.fn.pumvisible() ~= 0 then
          -- If popup is visible, confirm selected item or add new line otherwise,
          local item_selected = vim.fn.complete_info()['selected'] ~= -1
          return item_selected and keys['ctrl-y'] or keys['ctrl-y_cr']
        else
          -- If popup is not visible, use plain `<CR>`. You might want to customize
          -- according to other plugins. For example, to use 'mini.pairs', replace
          -- next line with `return require('mini.pairs').cr()`.
          return keys['cr']
        end
      end

      mini_completion_map("i", "<CR>", "v:lua._G.cr_action()")
    end
  },

  -- mini.statusline -----------------------------------------------------------------------

  {
    "echasnovski/mini.statusline",
    lazy = false,
    version = false,

    opts = {
      content = {
        active = function()
          local MiniStatusline = require("mini.statusline")
          local LazyStatus     = require("lazy.status")

          local macro         = ministatusline_macro_recording()
          local mode, mode_hl = ministatusline_modes()
          local git           = ministatusline_branch_name()
          local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
          local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
          local fileinfo      = ministatusline_file_info()
          local fileencoding  = ministatusline_file_encoding()
          local location      = ministatusline_location()
          local search        = ministatusline_search_count()
          local visual_sel    = ministatusline_visual_selection_information()
          local updates       = LazyStatus.has_updates() and LazyStatus.updates() or ""

          return MiniStatusline.combine_groups({
            { hl = mode_hl,                         strings = { mode } },
            { hl = "MiniStatuslineMacro",           strings = { macro } },
            { hl = "MiniStatuslineFileinfo",        strings = { fileinfo } },
            { hl = "MiniStatuslineFilename",        strings = { filename } },
            { hl = "MiniStatuslineDevinfo",         strings = { fileencoding, git, diff } },
            '%<', -- Mark general truncate point
            '%=', -- End left alignment
            { hl = "MiniStatuslineVisualSelection", strings = { visual_sel } },
            { hl = "MiniStatuslineSearchInfo",      strings = { search } },
            { hl = "MiniStatuslineUpdates",         strings = { updates } },
            { hl = "MiniStatuslineLocation",        strings = { location } },
          })
        end
      }
    },

    config = function(_, opts)
      vim.api.nvim_set_hl(
        0,
        "MiniStatuslineFileinfo",
        {
          fg = get_color("Comment", "fg"),
          bg = get_color("StatusLine", "bg")
        }
      )

      vim.api.nvim_set_hl(
        0,
        "MiniStatuslineFilename",
        {
          fg = get_color("Comment", "fg"),
          bg = get_color("StatusLine", "bg")
        }
      )

      vim.api.nvim_set_hl(
        0,
        "MiniStatuslineLocation",
        {
          fg = get_color("Comment", "fg"),
          bg = get_color("StatusLine", "bg")
        }
      )

      vim.api.nvim_set_hl(
        0,
        "MiniStatuslineMacro",
        {
          fg = get_color("Special", "fg"),
          bg = get_color("StatusLine", "bg")
        }
      )

      vim.api.nvim_set_hl(
        0,
        "MiniStatuslineDevinfo",
        {
          fg = get_color("Comment", "fg"),
          bg = get_color("StatusLine", "bg")
        }
      )

      vim.api.nvim_set_hl(
        0,
        "MiniStatuslineSearchInfo",
        {
          fg = get_color("Special", "fg"),
          bg = get_color("StatusLine", "bg")
        }
      )

      vim.api.nvim_set_hl(
        0,
        "MiniStatuslineUpdates",
        {
          fg = get_color("Special", "fg"),
          bg = get_color("StatusLine", "bg")
        }
      )

      vim.api.nvim_set_hl(
        0,
        "MiniStatuslineVisualSelection",
        {
          fg = get_color("Special", "fg"),
          bg = get_color("StatusLine", "bg")
        }
      )

      require("mini.statusline").setup(opts)
    end
  },

  -- mini.splitjoin ------------------------------------------------------------------------

  {
    "echasnovski/mini.splitjoin",
    version = false,
    lazy = false,

    opts = {
      detect = {
        separator = "[,;]"
      }
    },
  },

  -- mini.tabline --------------------------------------------------------------------------

  {
    "echasnovski/mini.tabline",
    version = false,
    lazy = false,

    opts = {
      tabpage_section = "right"
    },
  },

  -- mini.trailspace -----------------------------------------------------------------------

  {
    "echasnovski/mini.trailspace",
    version = false,
    lazy = false,
    keys = {
      {
        "<Leader>tw",
        "<Cmd>lua MiniTrailspace.trim()<CR>",
        desc = "Trim Whitespaces",
        silent = true
      },
      {
        "<Leader>tl",
        "<Cmd>lua MiniTrailspace.trim_last_lines()<CR>",
        desc = "Trim Lastlines",
        silent = true
      },
    },
    opts = { },

    config = function(_, opts)
      require("mini.trailspace").setup(opts)

      -- HACK: We need to disabel the mini.trailspace and enable when a new buffer is
      -- created to avoid interference with the dashboard snacks.nvim. See:
      --
      --  https://github.com/echasnovski/mini.nvim/issues/1395
      --
      --  TODO: Can we improve this?
      vim.g.minitrailspace_disable = true

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.g.minitrailspace_disable = false
        end
      })
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
