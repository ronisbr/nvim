-- Plugin configuration: zk.nvim -----------------------------------------------------------

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
    config = function()
      require("zk").setup({
        picker = "telescope",
        lsp = {
          cmd = { "zk", "lsp" },
          name = "zk"
        }
      })
    end
  }
}
