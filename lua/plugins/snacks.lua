-- Description -----------------------------------------------------------------------------
--
-- Configuration of snacks.nvim.
--
-- -----------------------------------------------------------------------------------------

local M = { }
local map = vim.keymap.set

-- Toggle the floating terminal.
function M.toggle_terminal()
  -- We need to compute the size of the window and terminal here to make sure the latter
  -- appears centered on the screen.
  local win_width   = vim.api.nvim_list_uis()[1].height
  local win_height  = vim.api.nvim_list_uis()[1].width
  local term_width  = math.floor(win_width * 0.8)
  local term_height = math.floor(win_height * 0.8)
  local term_row    = math.floor((win_width - term_width) / 2)
  local term_col    = math.floor((win_height - term_height) / 2)

  Snacks.terminal.toggle(
    "/bin/zsh",
    {
      win = {
        border = "rounded",
        col = term_col,
        row = term_row,
        height = 0.8,
        width = 0.8,
        keys = {
          -- The default keybindings for changing to normal mode after pressing <esc> two
          -- times conflicts with bracketed paste mode in Julia REPL. Hence, we will disable
          -- it. Thus, to change to normal mode, we need to enter <C-\><C-n>.
          term_normal = {"<esc>", "<esc>", mode = "t"}
        }
      }
    }
  )
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,

  opts = {
    -- bigfile -----------------------------------------------------------------------------

    bigfile = {
      enabled = true
    },

    -- dashboard ---------------------------------------------------------------------------

    dashboard = {
      enabled = true,

      preset = {
        keys = {
          {
            icon = " ",
            key = "f",
            desc = "Find File",
            action = ":lua require('mini.pick').builtin['files']()"
          },
          {
            icon = " ",
            key = "n",
            desc = "New File",
            action = ":ene | startinsert"
          },
          {
            icon = " ",
            key = "t",
            desc = "Find Text",
            action = ":lua require('fzf-lua').live_grep_native()"
          },
          {
            icon = " ",
            key = "r",
            desc = "Recent Files",
            action = ":lua require('fzf-lua').oldfiles()"
          },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua require('mini.extra').pickers.explorer({cwd = vim.fn.stdpath('config')})"
          },
          {
            icon = " ",
            key = "s",
            desc = "Restore Session",
            section = "session"
          },
          {
            icon = "",
            key = "g",
            desc = "LazyGit",
            action = ":lua Snacks.lazygit()",
            enabled = package.loaded.lazy ~= nil
          },
          {
            icon = "󰒲 ",
            key = "L",
            desc = "Lazy",
            action = ":Lazy",
            enabled = package.loaded.lazy ~= nil
          },
          {
            icon = " ",
            key = "q",
            desc = "Quit",
            action = ":qa"
          },
        },
      },

      sections = {
        {
          section = "header"
        },
        {
          text = {
            "────────────────────────────────────────────────────────────",
            hl = "String"
          },
          padding  = 1,
        },
         {
          gap     = 1,
          padding = 1,
          section = "keys",
        },
        {
          text = {
            "────────────────────────────────────────────────────────────",
            hl = "String"
          },
          padding  = 1,
        },
        {
          gap     = 0,
          icon    = " ",
          indent  = 2,
          padding = 1,
          section = "recent_files",
          title   = "Recent Files",
        },
        {
          gap     = 0,
          icon    = " ",
          indent  = 2,
          padding = 1,
          section = "projects",
          title   = "Projects",
        },
        {
          text = {
            "────────────────────────────────────────────────────────────",
            hl = "String"
          },
          padding  = 1,
        },
        {
          section = "startup"
        },
      },
    },

    -- indent ------------------------------------------------------------------------------

    indent = {
      chunk = { enabled = true },
      enabled = true,
      indent = { only_scope = true }
    },

    -- input -------------------------------------------------------------------------------

    input = { enabled = true },

    -- notifier ----------------------------------------------------------------------------

    notifier = {
      enabled = true,
      timeout = 3000,
    },

    -- scope -------------------------------------------------------------------------------

    scope = { enabled = true },
    dim = { enabled = true },

    -- quickfile ---------------------------------------------------------------------------

    quickfile = { enabled = true },

    -- Styles ------------------------------------------------------------------------------

    styles = {
      lazygit = {
        wo = {
          winhighlight = "Normal:Normal"
        }
      },

      terminal = {
        wo = {
          winhighlight = "Normal:Normal"
        }
      },

      zen = {
        backdrop = {
          blend = 25,
          transparent = true
        },
      }
    }
  },

  keys = {
    {
      "<leader>sz",
      function() Snacks.zen() end,
      desc = "Toggle Zen Mode"
    },
    {
      "<leader>s.",
      function() Snacks.scratch() end,
      desc = "Toggle Scratch Buffer"
    },
    {
      "<leader>sS",
      function() Snacks.scratch.select() end,
      desc = "Select Scratch Buffer"
    },
    {
      "<leader>sn",
      function() Snacks.notifier.show_history() end,
      desc = "Notification History"
    },
    {
      "<leader>stt",
      M.toggle_terminal,
      desc = "Toggle Floating Terminal"
    },
    {
      "<leader>sr",
      function() Snacks.rename.rename_file() end,
      desc = "Rename File"
    },
    {
      "<leader>sgb",
      function() Snacks.gitbrowse() end,
      desc = "Git Browse"
    },
    {
      "<leader>sgB",
      function() Snacks.git.blame_line() end,
      desc = "Git Blame Line"
    },
    {
      "<leader>sgf",
      function() Snacks.lazygit.log_file() end,
      desc = "Lazygit Current File History"
    },
    {
      "<leader>sgg",
      function() Snacks.lazygit() end,
      desc = "Lazygit"
    },
    {
      "<leader>sgl",
      function() Snacks.lazygit.log() end,
      desc = "Lazygit Log (cwd)"
    },
    {
      "<leader>sd",
      function() Snacks.notifier.hide() end,
      desc = "Dismiss All Notifications"
    },
    {
      "<F5>",
      M.toggle_terminal,
      desc = "Toggle Floating Terminal",
      mode = {"i", "n"}
    },
  },

  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded).
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end

        _G.bt = function()
          Snacks.debug.backtrace()
        end

        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Use Snacks to delete buffers using the abbreviation `:bd`.
        vim.keymap.set("c", "bd", "lua Snacks.bufdelete()", { silent = true })


        -- Toggle Mappings -----------------------------------------------------------------

        Snacks.toggle.option(
          "background",
          {
            off = "light",
            on = "dark",
            name = "Dark Background"
          }
        ):map("<leader>stb")

        Snacks.toggle.option(
          "conceallevel",
          { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }
        ):map("<leader>stc")

        Snacks.toggle.diagnostics():map("<leader>std")

        Snacks.toggle.line_number():map("<leader>stl")

        Snacks.toggle.inlay_hints():map("<leader>sth")

        Snacks.toggle.option(
          "relativenumber",
          { name = "Relative Number" }
        ):map("<leader>str")

        Snacks.toggle.option(
          "wrap",
          { name = "Wrap" }
        ):map("<leader>stw")

        -- Keymaps for the Plugins ---------------------------------------------------------

        -- terminal --

        map(
          "t",
          "<F5>",
          "<C-\\><C-n>:lua require('snacks').terminal.toggle('/bin/zsh')<CR>",
          { silent = true }
        )

        -- Additional Configuraton -----------------------------------------------------------

        -- Use vim.notify to show LSP progress.
        vim.api.nvim_create_autocmd("LspProgress", {
          callback = function(ev)
            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
            vim.notify(vim.lsp.status(), "info", {
              id = "lsp_progress",
              title = "LSP Progress",
              opts = function(notif)
                notif.icon = ev.data.params.value.kind == "end" and " "
                or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
              end,
            })
          end,
        })

        -- Neovide Configration ------------------------------------------------------------

        -- We add a border to the lazygit window when using Neovide to make it look better
        -- given the rounded corners.
        -- if vim.g.neovide then
        --   require("snacks").config.styles.lazygit.border = "rounded"
        -- end
      end,
    })
  end,
}

-- vim:ts=2:sts=2:sw=2:et
