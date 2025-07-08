-- Description -----------------------------------------------------------------------------
--
-- Configuration of snacks.nvim.
--
-- -----------------------------------------------------------------------------------------

local M = { }
local map = vim.keymap.set

-- Toggle the floating terminal.
function M.toggle_terminal()
  Snacks.terminal.toggle(
    "/bin/zsh",
    {
      win = {
        border = "rounded",
        height = 0.8,
        width = 0.8
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
            action = ":Pick files",
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
            action = ":Pick grep_live"
          },
          {
            icon = " ",
            key = "r",
            desc = "Recent Files",
            action = ":Pick oldfiles"
          },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua MiniFiles.open('~/.config/nvim')"
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

    -- explorer ----------------------------------------------------------------------------

    explorer = { enabled = false },

    -- indent ------------------------------------------------------------------------------

    indent = {
      chunk = { enabled = true },
      enabled = true,
      indent = { only_scope = true }
    },

    -- input -------------------------------------------------------------------------------

    input = { enabled = false },

    -- notifier ----------------------------------------------------------------------------

    notifier = {
      enabled = true,
      timeout = 3000,
    },

    -- picker ------------------------------------------------------------------------------

    picker = { enabled = false, },

    -- scope -------------------------------------------------------------------------------

    scope = { enabled = true },
    dim = { enabled = true },

    -- quickfile ---------------------------------------------------------------------------

    quickfile = { enabled = true },

    -- Styles ------------------------------------------------------------------------------

    styles = {
      lazygit = {
        border = "rounded"
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
      "<leader>sd",
      function() Snacks.notifier.hide() end,
      desc = "Dismiss All Notifications"
    },
    {
      "<leader>sn",
      function() Snacks.notifier.show_history() end,
      desc = "Notification History"
    },
    {
      "<leader>sr",
      function() Snacks.rename.rename_file() end,
      desc = "Rename File"
    },
    {
      "<leader>sS",
      function() Snacks.scratch.select() end,
      desc = "Select Scratch Buffer"
    },
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

    -- Buffers -----------------------------------------------------------------------------

    {
      "<leader>sbc",
      function() Snacks.bufdelete.all() end,
      desc = "Delete All Buffers"
    },
    {
      "<leader>sbd",
      function() Snacks.bufdelete() end,
      desc = "Delete Current Buffer"
    },

    -- Git ---------------------------------------------------------------------------------

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

    -- Terminal ----------------------------------------------------------------------------

    {
      "<leader>stt",
      M.toggle_terminal,
      desc = "Toggle Floating Terminal"
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

        -- Show LSP progress using notifications.
        local progress = vim.defaulttable()

        vim.api.nvim_create_autocmd(
          "LspProgress",
          {
            callback = function(ev)
              local client = vim.lsp.get_client_by_id(ev.data.client_id)
              local value = ev.data.params.value

              if not client or type(value) ~= "table" then
                return
              end

              local p = progress[client.id]

              for i = 1, #p + 1 do
                if i == #p + 1 or p[i].token == ev.data.params.token then
                  p[i] = {
                    token = ev.data.params.token,
                    msg = ("[%3d%%] %s%s"):format(
                      value.kind == "end" and 100 or value.percentage or 100,
                      value.title or "",
                      value.message and (" **%s**"):format(value.message) or ""
                    ),
                    done = value.kind == "end",
                  }
                  break
                end
              end

              local msg = {}

              progress[client.id] = vim.tbl_filter(
                function(v)
                  return table.insert(msg, v.msg) or not v.done
                end,
                p
              )

              local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
              vim.notify(
                table.concat(msg, "\n"),
                "info",
                {
                  id = "lsp_progress",
                  title = client.name,
                  opts = function(notif)
                    if #progress[client.id] == 0 then
                      notif.icon = " "
                    else
                      notif.icon = spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                    end
                  end
                }
              )
            end,
          }
        )

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
