-- Plugin configuration: noice.nvim --------------------------------------------------------

return {
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        format = {
          search_down = { kind = "search", pattern = "^/",  icon = " ", lang = "regex" },
          search_up   = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        },
      },

      commands = {
        last = {
          opts = {
            -- Add new line between the header and the message.
            format = {
              "{level} ",
              "{date} ",
              "{event}",
              { "{kind}", before = { ".", hl_group = "NoiceFormatKind" } },
              " ",
              "{title} ",
              "{cmdline}\n\n",
              "{message}",
            },
            win_options = {
              winhighlight = {
                Normal = "Normal",
                FloatBorder = "Normal"
              },
            },
          },
        },
      },
    }
  }
}
