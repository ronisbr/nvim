-- Description -----------------------------------------------------------------------------
--
-- Configuration of snacks.nvim.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.now(
  function()
    MiniDeps.add({ source = "folke/snacks.nvim" })

    function toggle_terminal()
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


    require("snacks").setup({
      -- bigfile ---------------------------------------------------------------------------

      bigfile = { enabled = false },

      -- dashboard -------------------------------------------------------------------------

      dashboard = {
        enabled = false,

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
          { section = "header" },
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
        },
      },

      -- explorer --------------------------------------------------------------------------

      explorer = { enabled = false },

      -- indent ----------------------------------------------------------------------------

      indent = { enabled = false },

      -- input -----------------------------------------------------------------------------

      input = { enabled = false },

      -- lazygit ---------------------------------------------------------------------------

      lazygit = { enabled = false },

      -- notifier --------------------------------------------------------------------------

      notifier = { enabled = false, },

      -- picker ----------------------------------------------------------------------------

      picker = { enabled = false, },

      -- scope -----------------------------------------------------------------------------

      scope = { enabled = false },
      dim = { enabled = false },

      -- quickfile -------------------------------------------------------------------------

      quickfile = { enabled = false },

      -- Styles ----------------------------------------------------------------------------

      styles = {
        lazygit = { border = "rounded" },

        zen = {
          backdrop = {
            blend = 25,
            transparent = true
          },
        }
      }
    })
  end
)

-- vim:ts=2:sts=2:sw=2:et
