-- Description -----------------------------------------------------------------------------
--
-- Configuration for aiwaku.nvim.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "juhaku/aiwaku.nvim", depends = { "nvim-lua/plenary.nvim" } })

    require("aiwaku").setup({
      cmd = {
        "claude"
      },
      lsp_code_actions = {
        { title = "Send to Aiwaku" },
        {
          title = "AI: Explain Code",
          prompt = "Explain the following code:",
        },
        {
          title = "AI: Improve and Correct English for Selection",
          prompt = "Improve and correct English for:",
        },
        {
          title = "AI: Improve and Correct English in File",
          prompt = "Improve and correct English for:",
          buffer = true
        },
        {
          title = "AI: Improve the Performance",
          prompt = "Improve the performance of the following code:",
        },
      }
    })

    local aiwaku_misc = require("misc.aiwaku")
    local opts = { noremap = true, silent = true }

    vim.keymap.set(
      "n",
      "<leader>ac",
      function() aiwaku_misc.select_cmd() end,
      {
        desc    = "Aiwaku: select AI CLI",
        noremap = true,
        silent  = true
      }
    )

    vim.keymap.set(
      "n",
      "<C-i>",
      function()
        aiwaku_misc.prompt_and_send()
      end,
      {
        desc    = "Aiwaku: prompt and send current line",
        noremap = true,
        silent  = true
      }
    )

    vim.keymap.set(
      "v",
      "<C-i>",
      function()
        -- '< and '> are not updated yet in a Lua visual mapping. Hence, we read the live
        -- selection positions now while still in visual mode..
        local ls = vim.fn.getpos("v")[2]
        local le = vim.fn.getcurpos()[2]

        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
          "nx",
          false
        )

        aiwaku_misc.prompt_and_send(ls, le)
      end,
      {
        desc    = "Aiwaku: prompt and send selection",
        noremap = true,
        silent  = true
      }
    )
  end
)
