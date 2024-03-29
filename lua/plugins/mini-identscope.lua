-- Plugin configuration: mini-indentscope --------------------------------------------------

return {
  "echasnovski/mini.indentscope",
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "NeogitPopup",
        "Trouble",
        "alpha",
        "dashboard",
        "floaterm",
        "help",
        "lazy",
        "lazyterm",
        "mason",
        "neo-tree",
        "neogit",
        "notify",
        "toggleterm",
      },
      callback = function()
        vim.b.miniindentscope_disable = true
      end,
    })
  end
}
