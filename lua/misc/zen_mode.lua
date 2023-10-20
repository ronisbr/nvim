-- Description -----------------------------------------------------------------------------
--
-- Functions related to the Zen Mode.
--
-- -----------------------------------------------------------------------------------------

local M = {}

function M.toogle_zen_mode()
  if vim.g.ronisbr_zen_mode then
    vim.cmd("close")
    require("lualine").hide({ place = { "winbar" }, unhide = true })
    vim.g.miniindentscope_disable = false

    vim.g.ronisbr_zen_mode = false
  else
    require("lualine").hide({ place = { "winbar" }, unhide = false })
    vim.g.miniindentscope_disable = true
    vim.cmd("ZenMode")

    vim.g.ronisbr_zen_mode = true
  end
end

return M

