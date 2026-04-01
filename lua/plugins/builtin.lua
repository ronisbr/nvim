-- Description -----------------------------------------------------------------------------
--
-- Configurations related to built-in plugins in Neovim.
--
-- -----------------------------------------------------------------------------------------

-- undotree --------------------------------------------------------------------------------

vim.cmd("packadd nvim.undotree")

vim.api.nvim_create_user_command(
  "Undotree",
  function()
    require("undotree").open({ command = "45vnew" })
  end,
  {}
)

