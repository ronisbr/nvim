-- Description -----------------------------------------------------------------------------
--
-- Configuration for GitHub Copilot.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "github/copilot.vim",
    event = "BufEnter",
    config = function()
      -- Prevent Copilot from mapping <Tab> globally.
      vim.g.copilot_no_tab_map = true

      vim.keymap.set(
        "i",
        "<C-g>",
        "copilot#Accept(\"\")",
        {expr = true, replace_keycodes = false, silent = true}
      )

      local copilot_keymaps = {
        { key = "<C-k>", cmd = "<Plug>(copilot-accept-word)", desc = "Accept Word"         },
        { key = "<C-l>", cmd = "<Plug>(copilot-accept-line)", desc = "Accept Line"         },
        { key = "<C-.>", cmd = "<Plug>(copilot-next)",        desc = "Next Suggestion"     },
        { key = "<C-,>", cmd = "<Plug>(copilot-previous)",    desc = "Previous Suggestion" },
        { key = "<C-/>", cmd = "<Plug>(copilot-dismiss)",     desc = "Dismiss Suggestion"  },
      }

      for _, map in ipairs(copilot_keymaps) do
        vim.keymap.set("i", map.key, map.cmd, { desc = map.desc, silent = true })
      end
    end
  },

  -- It is recommended to install the luarocks package `tiktoken_core`. This can be done
  -- by installing Luarocks using `brew`, and then running:
  --
  --     luarocks install --lua-version 5.1 tiktoken_core
  --
  -- You also need to update the `LUA_CPATH` environment variable to include the path to the
  -- `tiktoken_core` library. This can be done by adding the following line to your shell
  -- configuration file (e.g., `~/.bashrc`, `~/.zshrc`):
  --
  --     export LUA_CPATH="./?.so;/usr/local/lib/lua/5.1/?.so;/opt/homebrew/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;${HOME}/.luarocks/lib/lua/5.1/?.so"

  {
    "CopilotC-Nvim/CopilotChat.nvim",

    cmd = {
      "CopilotChat",
      "CopilotChatAgents",
      "CopilotChatCommit",
      "CopilotChatDocs",
      "CopilotChatExplain",
      "CopilotChatFix",
      "CopilotChatModels",
      "CopilotChatPrompts",
      "CopilotChatReview",
      "CopilotChatTests",
      "CopilotChatToggle",
    },

    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" },
      { "echasnovski/mini.pick" }
    },

    build = "make tiktoken",

    opts = {
      headers = {
        user = "👤 You: ",
        assistant = "🤖 Copilot: ",
        tool = "🔧 Tool: ",
      },

      prompts = {
        SpellingAndGrammar = {
          prompt = "Please check the spelling and grammar for the current buffer.",
          description = "Spell and grammar check",
          context = "buffer"
        },
      },

      separator = '━━',
      show_folds = false,
    },

    config = function(_, opts)
      require("CopilotChat").setup(opts)

      vim.api.nvim_create_autocmd(
        "BufEnter",
        {
          pattern = "copilot-*",
          callback = function()
            vim.opt_local.colorcolumn    = ""
            vim.opt_local.conceallevel   = 0
            vim.opt_local.number         = false
            vim.opt_local.relativenumber = false
          end,
        })
    end
  },
}
