-- Description -----------------------------------------------------------------------------
--
-- Configuration of mini.nvim and its modules.
--
-- -----------------------------------------------------------------------------------------

-- mini.align ------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.align" })

    require("mini.align").setup({})
  end
)

-- mini.clue -------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.clue" })

    local miniclue = require("mini.clue")

    -- Compute the mini.clue window width dinamically.
    local function miniclue_compute_dynamic_width(buf_id)
      local max_width = 0.4 * vim.o.columns
      local widths = vim.tbl_map(
        vim.fn.strdisplaywidth,
        vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
      )

      table.sort(widths)

      for i = #widths, 1, -1 do
        if widths[i] <= max_width then
          return widths[i]
        end
      end

      return max_width
    end

    local function miniclue_win_config(buf_id)
      return {
        border = "rounded",
        width = miniclue_compute_dynamic_width(buf_id)
      }
    end

    miniclue.setup({
      clues = {
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),

        -- Description of Mapping Groups -------------------------------------------------

        { mode = "n", keys = "<Leader>c", desc = "+Code" },
        { mode = "n", keys = "<Leader>f", desc = "+Find" },
        { mode = "n", keys = "<Leader>o", desc = "+Open" },
        { mode = "n", keys = "<Leader>s", desc = "+Snacks" },
        { mode = "n", keys = "<Leader>t", desc = "+Text" },

        { mode = "n", keys = "<Leader>sb", desc = "+Buffers" },
        { mode = "n", keys = "<Leader>sg", desc = "+Git" },
        { mode = "n", keys = "<Leader>st", desc = "+Toggle" },
      },

      -- Set the triggers that will show miniclue window.
      triggers = {
        -- Leader Triggers ---------------------------------------------------------------

        { mode = "n", keys = "<Leader>" },
        { mode = "x", keys = "<Leader>" },

        -- Built-in Completion -----------------------------------------------------------

        { mode = "i", keys = "<C-x>" },

        -- `g` key -----------------------------------------------------------------------

        { mode = "n", keys = "g" },
        { mode = "x", keys = "g" },

        -- Marks -------------------------------------------------------------------------

        { mode = "n", keys = "\"" },
        { mode = "n", keys = "`" },
        { mode = "x", keys = "\"" },
        { mode = "x", keys = "`" },

        -- Registers ---------------------------------------------------------------------

        { mode = "n", keys = "\"" },
        { mode = "x", keys = "\"" },
        { mode = "i", keys = "<C-r>" },
        { mode = "c", keys = "<C-r>" },

        -- Window Commands ---------------------------------------------------------------

        { mode = "n", keys = "<C-w>" },

        -- `z` key -----------------------------------------------------------------------

        { mode = "n", keys = "z" },
        { mode = "x", keys = "z" },
      },

      window = {
        delay = 0,
        config = miniclue_win_config,
        scroll_down = "<C-f>",
        scroll_up = "<C-b>",
      },
    })
  end
)

-- mini.completion -------------------------------------------------------------------------

MiniDeps.now(
  function()
    MiniDeps.add({ source = "echasnovski/mini.completion" })

    require("mini.completion").setup(opts)

    -- Keymaps -----------------------------------------------------------------------------

    local function mini_completion_map(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { noremap = true, expr = true })
    end

    -- Use <Tab> and <S-Tab> to navigate through completion items.
    mini_completion_map("i", "<Tab>",   "pumvisible() ? '<C-n>' : '<Tab>'")
    mini_completion_map("i", "<S-Tab>", "pumvisible() ? '<C-p>' : '<S-Tab>'")

    -- Configure a more consistent behavior of <CR>.
    _G.cr_action = function()
      -- If there is selected item in popup, accept it with <C-y>
      if vim.fn.complete_info()["selected"] ~= -1 then return '\25' end
      -- Fall back to plain `<CR>`.
      return "\r"
    end

    mini_completion_map("i", "<CR>", "v:lua.cr_action()")
  end
)

-- mini.diff -------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.diff" })

    require("mini.diff").setup({})
  end
)

-- mini.extra ------------------------------------------------------------------------------

MiniDeps.now(
  function()
    MiniDeps.add({ source = "echasnovski/mini.extra" })

    require("mini.extra").setup({})
  end
)

-- mini.files ------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.files" })

    require("mini.files").setup({
      mappings = {
        go_in_plus = "<Enter>"
      }
    })

    -- Keymaps -----------------------------------------------------------------------------

    local function mini_files_map(mode, lhs, rhs, desc)
      return vim.keymap.set(mode, lhs, rhs, { desc = desc, noremap = true, silent = true })
    end

    mini_files_map(
      "n",
      "<Leader>.",
      function()
        MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
      end,
      "Open Mini.files in Current Dir."
    )

    mini_files_map("n", "<Leader>ff", MiniFiles.open, "Open Mini.files")

    -- Autocmd to configure the mini.files window.
    vim.api.nvim_create_autocmd(
      "User",
      {
        pattern = "MiniFilesWindowOpen",
        callback = function(args)
          local win_id     = args.data.win_id
          local config     = vim.api.nvim_win_get_config(win_id)
          config.border    = "rounded"
          config.title_pos = "right"

          vim.api.nvim_win_set_config(win_id, config)
        end
      }
    )

    -- Mapping to toggle hidden files in the mini.files window.
    local show_hidden_files = true

    local filter__show_hidden_files = function(fs_entry) return true end

    local filter__hide_hidden_files = function(fs_entry)
      return not vim.startswith(fs_entry.name, ".")
    end

    local toggle_hidden_files = function()
      show_hidden_files = not show_hidden_files
      local new_filter =
      show_hidden_files and filter__show_hidden_files or filter__hide_hidden_files

      MiniFiles.refresh({
        content = {
          filter = new_filter
        }
      })
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local buf_id = args.data.buf_id

        vim.keymap.set(
          "n",
          "g.",
          toggle_hidden_files,
          { buffer = buf_id }
        )
      end,
    })

    -- Always start the explorer without showing the hidden files.
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesExplorerOpen",
      callback = function(args)
        show_hidden_files = false
        MiniFiles.refresh({
          content = {
            filter = filter__hide_hidden_files
          }
        })
      end,
    })
  end
)

-- mini.hipatterns -------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.hipatterns" })

    local hipatterns = require("mini.hipatterns")

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
)

-- mini.icons ------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.icons" })

    require("mini.icons").setup({})
  end
)

-- mini.indentscope ------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.indentscope" })

    require("mini.indentscope").setup({
      draw = { delay = 100, },
      symbol = "│"
    })

    MiniIndentscope.config.draw.animation = MiniIndentscope.gen_animation.none()

    vim.api.nvim_create_autocmd(
      "FileType",
      {
        pattern = {
          "help",
          "dashboard",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end
      }
    )
  end
)

-- mini.misc -------------------------------------------------------------------------------

MiniDeps.now(
  function()
    MiniDeps.add({ source = "echasnovski/mini.misc" })

    local MiniMisc = require("mini.misc")

    MiniMisc.setup({})

    MiniMisc.setup_auto_root(
      nil,
      function(path)
        return vim.fs.dirname(path)
      end
    )

    MiniMisc.setup_restore_cursor()
  end
)

-- mini.move -------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.move" })

    require("mini.move").setup({})
  end
)

-- mini.pick -------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.pick", depends = { "echasnovski/mini.extra" } })

    local MiniPick  = require("mini.pick")
    local MiniExtra = require("mini.extra")

    local minipick_window_config = function()
      local height = math.floor(0.618 * vim.o.lines)
      local width  = math.floor(0.618 * vim.o.columns)

      return {
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
        border = "rounded",
      }
    end

    MiniPick.setup({
      window = {
        config = minipick_window_config
      }
    })

    vim.ui.select = MiniPick.ui_select

    -- Keymaps -----------------------------------------------------------------------------

   local function mini_pick_map(lhs, rhs, desc)
     return vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
   end

   mini_pick_map(
     "<Leader>/",
     function()
       require("mini.extra").pickers.buf_lines({ scope = "current" })
     end,
     "Fuzzily Search in Current Buffer"
   )

   mini_pick_map(
     "<Leader><Space>",
     function()
       require("mini.pick").builtin.files({})
     end,
     "Find Files in ./"
   )

   mini_pick_map(
     "<Leader>:",
     function()
       require("mini.extra").pickers.history({ scope = ":" })
     end,
     "Find in Command History"
   )

   mini_pick_map(
     "<Leader>,",
     function()
       require("mini.pick").builtin.buffers({})
     end,
     "Find Existing Buffers"
   )

   mini_pick_map(
     "<Leader>fe",
     function()
       require("mini.extra").pickers.explorer({})
     end,
     "Find in Explorer"
   )

   mini_pick_map(
     "<Leader>fh",
     function()
       require("mini.pick").builtin.help({})
     end,
     "Find Help"
   )

   mini_pick_map(
     "<Leader>fi",
     function()
       require("mini.pick").builtin.grep_live({})
     end,
     "Find with Grep"
   )

   mini_pick_map(
     "<Leader>fr",
     function()
       require("mini.extra").pickers.oldfiles({})
     end,
     "Find Recent Files"
   )

   mini_pick_map(
     "z=",
     function()
       require("mini.extra").pickers.spellsuggest({})
     end,
     "Show Spelling Suggestions"
   )
  end
)

-- mini.snippets ---------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.snippets" })

    local gen_loader = require('mini.snippets').gen_loader

    require('mini.snippets').setup({
      snippets = { gen_loader.from_lang() }
    })

    MiniSnippets.start_lsp_server()
  end
)

-- mini.splitjoin --------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.splitjoin" })

    require("mini.splitjoin").setup({
      detect = { separator = "[,;]" }
    })
  end
)

-- mini.trailspace -------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.trailspace" })

    require("mini.trailspace").setup({})

    -- HACK: We need to disabel the mini.trailspace and enable when a new buffer is
    -- created to avoid interference with the dashboard snacks.nvim. See:
    --
    --  https://github.com/echasnovski/mini.nvim/issues/1395
    --
    --  TODO: Can we improve this?
    vim.g.minitrailspace_disable = true

    vim.api.nvim_create_autocmd(
      "VimEnter",
      {
        callback = function()
          vim.g.minitrailspace_disable = false
        end
      }
    )

    -- Keymaps -----------------------------------------------------------------------------

    local function mini_trailspace_map(lhs, rhs, desc)
      return vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
    end

    mini_trailspace_map("<Leader>tw", MiniTrailspace.trim, "Trim Whitespaces")
    mini_trailspace_map("<Leader>tl", MiniTrailspace.trim_last_lines, "Trim Lastlines")
  end
)

--   -- mini.completion -----------------------------------------------------------------------
--
--   {
--     "echasnovski/mini.completion",
--     lazy = false,
--     version = false,
--     dependencies = {
--       -- We need to add this dependency here to ensure that the <Tab> behavior works as
--       -- intended, i.e., the <Tab> key will not complete the copilot suggestion.
--       "github/copilot.vim",
--       "echasnovski/mini.snippets"
--     },
--
--     opts = { },

-- vim:ts=2:sts=2:sw=2:et
