-- Description -----------------------------------------------------------------------------
--
-- Configuration of the plugin zk.nvim.
--
-- -----------------------------------------------------------------------------------------

local function zk_new_note()
  require("mini.pick").ui_select(
    {
      "Diário",
      "Notas",
      "Trabalho"
    }, {
      prompt = "Select the directory:",
    },
    function(choice)
      local cmd = require("zk.commands")

      if choice == "Diário" then
        cmd.get("ZkNew")({ dir = "Diário" })
      elseif choice == "Notas" then
        local title = vim.fn.input("Note Title: ")
        cmd.get("ZkNew")({ dir = "Notas", title = title })
      elseif choice == "Trabalho" then
        local title = vim.fn.input("Note Title: ")
        cmd.get("ZkNew")({ dir = "Trabalho", title = title })
      end
    end)
end

return {
  {
    "mickael-menu/zk-nvim",
    cmd = {
      "ZkNew",
      "ZkIndex",
      "ZkNewFromTitleSelection",
      "ZkNewFromContentSelection",
      "ZkCd",
      "ZkNotes",
      "ZkMatch",
      "ZkTags"
    },
    dependencies = {
      "echasnovski/mini.pick"
    },
    keys = {
      {
        "<leader>zn",
        zk_new_note,
        desc = "New Note",
        noremap = true,
        silent = true
      },
      {
        "<leader>zf",
        '<cmd>ZkNotes { excludeHrefs = { "Diário" }, sort = { "modified" } }<cr>',
        desc = "Find Notes",
        noremap = true,
        silent = true
      },
      {
        "<leader>zd",
        function()
          require("mini.extra").pickers.explorer({
            cwd = os.getenv("HOME") .. "/Nextcloud/zk"
          })
        end,
        desc = "Open zk Directory",
        noremap = true
      },
      {
        "<leader>zj",
        '<cmd>ZkNotes { hrefs = { "Diário" }, sort = { "path" } }<cr>',
        desc = "Find Journals",
        noremap = true,
        silent = true
      },
      {
        "<leader>zt",
        "<cmd>ZkTags<cr>",
        desc = "Find Tags",
        noremap = true
      },
    },
    version = false,

    config = function()
      require("zk").setup({
        picker = "minipick",
        lsp = {
          cmd = { "zk", "lsp" },
          name = "zk"
        }
      })
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
