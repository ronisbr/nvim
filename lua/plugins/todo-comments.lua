-- Plugin configuration: todo-comments.nvim ------------------------------------------------

local colors = {}

return {
  {
    "folke/todo-comments.nvim",
    init = function ()
      colors = require("nano-theme.colors").get()
    end,
    opts = {
      keywords = {
        FIX  = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }},
        TODO = { icon = " ", color = "todo" },
        HACK = { icon = " ", color = "warn" },
        WARN = { icon = " ", color = "warn", alt = { "WARNING", "XXX" } },
        PERF = { icon = "󰓅 ", color = "info", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "info", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "info", alt = { "TESTING", "PASSED", "FAILED" } },
      },

      colors = {
        error = { "Error",      colors.nano_critical_color },
        todo  = { "Todo",       colors.nano_salient_color },
        warn  = { "WarningMsg", colors.nano_popout_color },
        info  = { "Comment",    colors.nano_faded_color }
      }
    }
  }
}
