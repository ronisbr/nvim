-- Plugin configuration: bufferline.nvim ---------------------------------------------------

-- We will disable the buffer line because we will set the winbar and disable the status
-- line.
return {
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
}

-- return {
--   {
--     "akinsho/bufferline.nvim",
--     after = "nano-theme",
--     opts = {
--       highlights = require("nano-theme.groups.integrations.bufferline").get()
--     }
--   }
-- }
