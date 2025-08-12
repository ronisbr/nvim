-- Description -----------------------------------------------------------------------------
--
-- General utilizy functions.
--
-- -----------------------------------------------------------------------------------------

local M = {}

--- Return the color value of a given attribute from a highlight group.
--- @param hl_group string: The name of the highlight group.
--- @param attribute string: The attribute to retrieve (e.g., "fg", "bg").
--- @return string|nil: The color in "#RRGGBB" format, or nil if not found.
function M.get_color(hl_group, attribute)
  local hl = vim.api.nvim_get_hl(0, { name = hl_group })

  if hl[attribute] then
    return "#" .. string.format("%06x", hl[attribute])
  end

  return nil
end

return M
