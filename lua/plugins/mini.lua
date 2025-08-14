-- Description -----------------------------------------------------------------------------
--
-- Configuration of mini.nvim and its modules.
--
-- -----------------------------------------------------------------------------------------

local neovim_logo = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]] .. tostring(vim.version())

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

        { mode = "n", keys = "<Leader>b", desc = "+Buffer" },
        { mode = "n", keys = "<Leader>c", desc = "+Code" },
        { mode = "n", keys = "<Leader>f", desc = "+Find" },
        { mode = "n", keys = "<Leader>o", desc = "+Open" },
        { mode = "n", keys = "<Leader>n", desc = "+Notifications" },
        { mode = "n", keys = "<Leader>s", desc = "+Snacks" },
        { mode = "n", keys = "<Leader>t", desc = "+Text" },

        { mode = "n", keys = "<Leader>sb", desc = "+Buffers" },
        { mode = "n", keys = "<Leader>sg", desc = "+Git" },
        { mode = "n", keys = "<Leader>st", desc = "+Toggle" },

        { mode = "v", keys = "<Leader>b", desc = "+Buffer" },
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

    require("mini.completion").setup({
      delay = { completion = 700, info = 300, signature = 200 },
    })

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
          "terminal",
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

-- mini.notify -----------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.notify" })

    require("mini.notify").setup({})

    vim.notify = require("mini.notify").make_notify({
      ERROR = { duration = 10000 },
    })

    function mini_notify_map(lhs, rhs, desc)
      return vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
    end

    mini_notify_map("<leader>nd", MiniNotify.clear, "Dismiss All Notifications")
    mini_notify_map("<leader>ns", MiniNotify.show_history, "Notification History")

    -- Close the notification history buffer with `q`.
    vim.api.nvim_create_autocmd(
      "FileType",
      {
        pattern = { "mininotify-history" },
        callback = function(event)
          vim.keymap.set("n", "q", "<cmd>bd<cr>", { buffer = event.buf, silent = true })
        end,
    })
  end
)

-- mini.pick -------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "echasnovski/mini.pick", depends = { "echasnovski/mini.extra" } })

    local MiniPick  = require("mini.pick")

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

-- mini.starter ----------------------------------------------------------------------------

MiniDeps.now(
  function()
    MiniDeps.add({ source = "echasnovski/mini.starter" })

    -- Auxiliary Functions -----------------------------------------------------------------

    local function center_header(content)
      -- Compute the maximum width of the lines in the content.
      local max_width = 0

      for _, line in ipairs(content) do
        for _, unit in ipairs(line) do
          local width = vim.fn.strdisplaywidth(unit.string)

          if width > max_width then
            max_width = width
          end
        end
      end

      -- Detect header lines and pad them for center alignment
      local coords = {}
      vim.list_extend(coords, MiniStarter.content_coords(content, "header"))
      vim.list_extend(coords, MiniStarter.content_coords(content, "footer"))

      for _, c in ipairs(coords) do
        local line = content[c.line]

        -- Get total length of this header line.
        local line_width = 0

        for _, unit in ipairs(line) do
          line_width = line_width + vim.fn.strdisplaywidth(unit.string)
        end

        local pad = math.max(math.floor((max_width - line_width) / 2), 0)

        -- Add left padding on first unit
        local left_pad = #line > 0 and string.rep(" ", pad) or ""

        -- Insert the padding in the line as an empty item.
        table.insert(
          line,
          1,
          {
            string = left_pad,
            type = "empty"
          }
        )
      end

      return content
    end

    -- Return the footer for the mini.starter.
    local function mini_starter_footer()

      local num_plugins_str = ""

      if _G.__nvim_num_loaded_plugins then
        num_plugins_str = string.format("Loaded Plugins : %d", _G.__nvim_num_loaded_plugins)
      end

      -- Startup Time ----------------------------------------------------------------------

      local startup_time_str = ""
      if _G.__nvim_startup_time then
        startup_time_str = string.format("Startup Time   : %d ms", _G.__nvim_startup_time)
      end

      -- Footer ----------------------------------------------------------------------------

      -- Apply padding to make the centering nicer.
      local np_width     = vim.fn.strdisplaywidth(num_plugins_str)
      local st_width     = vim.fn.strdisplaywidth(startup_time_str)
      local max_width    = math.max(np_width, st_width)
      local np_right_pad = string.rep(" ", max_width - np_width)
      local st_right_pad = string.rep(" ", max_width - st_width)

      return "\n" ..
        num_plugins_str  .. np_right_pad .. "\n" ..
        startup_time_str .. st_right_pad .. "\n"
    end

    -- Setup -------------------------------------------------------------------------------

    local starter = require("mini.starter")

    local items = {
      { name = "Find File",    action = ":Pick files",                           section = "Actions" },
      { name = "New File",     action = ":ene | startinsert",                    section = "Actions" },
      { name = "Find Text",    action = ":Pick grep_live",                       section = "Actions" },
      { name = "Recent Files", action = ":Pick oldfiles",                        section = "Actions" },
      { name = "Config",       action = ":lua MiniFiles.open('~/.config/nvim')", section = "Actions" },
      { name = "LazyGit",      action = ":LazyGit",                              section = "Actions" },
      { name = "Quit",         action = ":qa",                                   section = "Actions" },
      starter.sections.recent_files(10, false, true),
    }

    starter.setup({
      header = neovim_logo .. "\n\n",
      items  = items,
      footer = mini_starter_footer,
      content_hooks = {
        starter.gen_hook.adding_bullet(),
        center_header,
        starter.gen_hook.aligning("center", "center"),
      }
    })

    -- Autocmds ----------------------------------------------------------------------------

    -- Create the an event to refresh the mini.starter after the `UIEnter`, updating the
    -- startupt time.
    vim.api.nvim_create_autocmd(
      "User",
      {
        pattern  = "MiniDepsFinished",
        once     = true,
        callback = function() 
          if not _G.__nvim_startup_time then
            local started = _G.__nvim_start_time
            if not started then return "" end
            local dt_ns = vim.uv.hrtime() - started
            local ms = math.floor(dt_ns / 1e6 + 0.5)
            _G.__nvim_startup_time = ms
          end

          if vim.bo.filetype == "ministarter" then MiniStarter.refresh() end
        end,
      }
    )

    vim.api.nvim_create_autocmd(
      "User",
      {
        pattern = {
          "MiniStarterOpened"
        },
        callback = function()
          -- Remove characters at the end of buffer.
          vim.opt_local.fillchars = "eob: "

          -- Hide the status line by changing its highlight group.
          local ns = vim.api.nvim_create_namespace("mini_starter_statusline_ns")
          vim.api.nvim_set_hl(ns, "StatusLine",   { link = "Normal" })
          vim.api.nvim_set_hl(ns, "StatusLineNC", { link = "Normal" })

          -- Apply the namespace to the current window (which shows the Starter buffer).
          vim.api.nvim_win_set_hl_ns(0, ns)
        end
      }
    )
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

-- vim:ts=2:sts=2:sw=2:et
