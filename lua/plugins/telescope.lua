-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to Telescope.
--
-- -----------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--                                    Local Functions                                     --
--------------------------------------------------------------------------------------------

local function _custom_buffer_fuzzy_find()
  require("telescope.builtin").current_buffer_fuzzy_find(
    require("telescope.themes").get_dropdown({
      winblend = 10,
      previewer = false,
    })
  )
end

local function _custom_live_grep()
  require("telescope.builtin").live_grep({
    grep_open_files = true,
    prompt_title = "Live Grep in Open Files",
  })
end

--------------------------------------------------------------------------------------------
--                                  Plugin Configuration                                  --
--------------------------------------------------------------------------------------------

return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",

    cmd = "Telescope",

    dependencies = {
      -- Plugin with ascynchronous programming using coroutines required by Telescope.
      "nvim-lua/plenary.nvim",
      -- Plugin to set `vim.ui.select` to Telescope.
      "nvim-telescope/telescope-ui-select.nvim",
      -- Native fuzzy finder for Telescope.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable "make" == 1
        end,
      },
      -- Pretty icons, requires a Nerd Font.
      {
        "nvim-tree/nvim-web-devicons",
        enabled = true
      },
    },

    keys = {
      {
        "<Leader>/",
        _custom_buffer_fuzzy_find,
        desc = "Fuzzily Search in Current Buffer",
        silent = true
      },
      {
        "<Leader>f/",
        _custom_live_grep,
        desc = "Find in Open Files",
        silent = true
      },
      {
        "<Leader>fb",
        ":Telescope buffers<CR>",
        desc = "Find Existing Buffers",
        silent = true
      },
      {
        "<Leader>fd",
        ":Telescope diagnostics<CR>",
        desc = "Find Diagnostics",
        silent = true
      },
      {
        "<Leader>ff",
        ":Telescope find_files<CR>",
        desc = "Find Files",
        silent = true
      },
      {
        "<Leader>fh",
        ":Telescope help_tags<CR>",
        desc = "Find Help",
        silent = true
      },
      {
        "<Leader>fi",
        ":Telescope live_grep<CR>",
        desc = "Find with Grep",
        silent = true
      },
      {
        "<Leader>fr",
        ":Telescope oldfiles<CR>",
        desc = "Find Recent Files (\".\" for repeat)",
        silent = true
      },
      {
        "<Leader>fs",
        ":Telescope builtin<CR>",
        desc = "Find Select Telescope",
        silent = true
      },
      {
        "<Leader>fw",
        ":Telescope grep_string<CR>",
        desc = "Find Current Word",
        silent = true
      },
    },

    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },

        defaults = {
          mappings = {
            i = {
              -- Close Telescope by pressing `ESC` one time.
              ["<ESC>"] = require("telescope.actions").close
            }
          }
        }
      })

      -- Load Extensions -------------------------------------------------------------------

      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
    end
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    cmd = "Telescope file_browser",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },

    keys = {
      {
        "<Leader>.",
        ":Telescope file_browser<CR>",
        desc = "Open File Browser in ./",
        silent = true
      }
    }
  }
}

-- vim:ts=2:sts=2:sw=2:et
