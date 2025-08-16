-- Description -----------------------------------------------------------------------------
--
-- Configuration for GitHub Copilot.
--
-- -----------------------------------------------------------------------------------------

-- copilot.vim -----------------------------------------------------------------------------

MiniDeps.now(
  function()
    MiniDeps.add({ source = "github/copilot.vim" })

    -- Prevent Copilot from mapping <Tab> globally.
    vim.g.copilot_no_tab_map = true

    -- Keymaps -----------------------------------------------------------------------------

    vim.keymap.set(
      "i",
      "<C-g>",
      "copilot#Accept(\"\")",
      {expr = true, replace_keycodes = false, silent = true}
    )

    local copilot_keymaps = {
      { key = "<M-/>", cmd = "<Plug>(copilot-suggest)",     desc = "Show Suggestion"     },
      { key = "<C-k>", cmd = "<Plug>(copilot-accept-word)", desc = "Accept Word"         },
      { key = "<C-l>", cmd = "<Plug>(copilot-accept-line)", desc = "Accept Line"         },
      { key = "<C-.>", cmd = "<Plug>(copilot-next)",        desc = "Next Suggestion"     },
      { key = "<C-,>", cmd = "<Plug>(copilot-previous)",    desc = "Previous Suggestion" },
      { key = "<C-/>", cmd = "<Plug>(copilot-dismiss)",     desc = "Dismiss Suggestion"  },
    }

    for _, map in ipairs(copilot_keymaps) do
      vim.keymap.set("i", map.key, map.cmd, { desc = map.desc, silent = true })
    end

    -- We must configure the mini.completion behavior here because copilot overrides it.
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

-- CopilotChat.nvim ------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({
      source = "CopilotC-Nvim/CopilotChat.nvim",
      depends = { "nvim-lua/plenary.nvim", }
    })

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

    require("CopilotChat").setup({
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
    })

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
)
