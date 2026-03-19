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
        { name = "Claude",  cmd = "claude" },
        { name = "Copilot", cmd = "copilot" },
        { name = "Codex",   cmd = "codex" }
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

    -- Disable visual noise in the aiwaku sidebar terminal.
    -- BufFilePost fires after nvim_buf_set_name(), which is when the buffer gets its
    -- "aiwaku://" name (set after the buffer is already in the window).
    local function clean_aiwaku_win(buf)
      vim.b[buf].miniindentscope_disable = true
      vim.b[buf].minitrailspace_disable  = true
      for _, w in ipairs(vim.fn.win_findbuf(buf)) do
        vim.wo[w].list = false
      end
    end

    vim.api.nvim_create_autocmd("BufFilePost", {
      pattern  = "aiwaku://*",
      callback = function(ev) clean_aiwaku_win(ev.buf) end,
    })

    vim.api.nvim_create_autocmd("BufWinEnter", {
      pattern  = "aiwaku://*",
      callback = function(ev) clean_aiwaku_win(ev.buf) end,
    })

    vim.api.nvim_create_autocmd("WinEnter", {
      pattern  = "aiwaku://*",
      callback = function(ev) clean_aiwaku_win(ev.buf) end,
    })

    local aiwaku_misc = require("misc.aiwaku")

    vim.keymap.set(
      "n",
      "<C-.>",
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
      "<C-.>",
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
