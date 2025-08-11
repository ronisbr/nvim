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

      bigfile = { enabled = true },

      -- dashboard -------------------------------------------------------------------------

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

      lazygit = {
        config = {
          git = { parseEmoji = true }
        }
      },

      -- notifier --------------------------------------------------------------------------

      notifier = { enabled = false, },

      -- picker ----------------------------------------------------------------------------

      picker = { enabled = false, },

      -- scope -----------------------------------------------------------------------------

      scope = { enabled = true },
      dim = { enabled = true },

      -- quickfile -------------------------------------------------------------------------

      quickfile = { enabled = true },

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

    -- Keymaps -----------------------------------------------------------------------------

    local map = vim.keymap.set

    map("n", "<leader>sr", Snacks.rename.rename_file, { desc = "Rename File" })
    map("n", "<leader>sS", Snacks.scratch.select, { desc = "Select Scratch Buffer" })
    map("n", "<leader>sz", Snacks.zen.zen, { desc = "Toggle Zen Mode" })
    map("n", "<leader>s.", Snacks.scratch.open, { desc = "Toggle Scratch Buffer" })

    -- Buffers .............................................................................

    map("n", "<leader>sbc", Snacks.bufdelete.all, { desc = "Delete All Buffers" })
    map("n", "<leader>sbd", Snacks.bufdelete.delete, { desc = "Delete Current Buffer" })

    -- Git .................................................................................

    map("n", "<leader>sgb", Snacks.gitbrowse.open, { desc = "Git Browse" })
    map("n", "<leader>sgB", Snacks.git.blame_line, { desc = "Git Blame Line" })
    map("n", "<leader>sgf", Snacks.lazygit.log_file, { desc = "Lazygit Current File History" })
    map("n", "<leader>sgg", Snacks.lazygit.open, { desc = "Lazygit" })
    map("n", "<leader>sgl", Snacks.lazygit.log, { desc = "Lazygit Log (cwd)" })

    -- Terminal ............................................................................

    map("n", "<leader>stt", toggle_terminal, { desc = "Toggle Floating Terminal" })
    map({"n", "i"}, "<F5>", toggle_terminal, { desc = "Toggle Floating Terminal" })
    map("t", "<F5>", "<C-\\><C-n>:lua require('snacks').terminal.toggle('/bin/zsh')<CR>")

    -- Toggle Mappings .....................................................................

    Snacks.toggle.diagnostics():map("<leader>std")
    Snacks.toggle.inlay_hints():map("<leader>sth")
    Snacks.toggle.line_number():map("<leader>stl")
    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>str")
    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>stw")

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
  end
)

-- vim:ts=2:sts=2:sw=2:et
