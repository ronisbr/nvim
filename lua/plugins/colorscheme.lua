-- Description -----------------------------------------------------------------------------
--
-- Configuration of the color schemes.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "ronisbr/nano-theme.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("nano-theme")

      if vim.fn.has("macunix") then
        local current_theme
        current_theme = vim.fn.system("defaults read -g AppleInterfaceStyle")
        current_theme = current_theme:gsub("\n", "")
        vim.o.background = (current_theme == "Dark") and "dark" or "light"

        -- Every 10s we check for the current theme in macOS and change the background color
        -- accordingly.
        local timer = vim.uv.new_timer()
        timer:start(10000, 10000, vim.schedule_wrap(
          function()
            current_theme = vim.fn.system("defaults read -g AppleInterfaceStyle")
            current_theme = current_theme:gsub("\n", "")
            vim.o.background = (current_theme == "Dark") and "dark" or "light"
          end
        ))
      else
        vim.o.background = "light"
      end
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
