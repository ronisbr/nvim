-- Description -----------------------------------------------------------------------------
--
-- Helpers to open padded floating windows over a backdrop. They are used by the floating
-- terminal, lazygit, and the aiwaku prompt.
--
-- The backdrop is a non-focusable window filled with the `FloatingTermBg` highlight, a
-- slightly tinted version of the floating window background. The content window is placed
-- on top of it, inset by the padding. In Neovide, both are merged into a single window with
-- a padding border, because stacked floating windows do not render well with its rounded
-- corners.
--
-- -----------------------------------------------------------------------------------------

local util = require("misc.util")

local M = {}

-- Window highlight overrides for the windows opened here. Every background group that a
-- floating (terminal) window may render with is remapped so that the content is tinted with
-- `FloatingTermBg`. In the TUI, remapping `Normal` is enough, but Neovide resolves the
-- background via `NormalFloat` and `NormalNC`.
M.winhl = table.concat(
  {
    "Normal:FloatingTermBg",
    "NormalNC:FloatingTermBg",
    "NormalFloat:FloatingTermBg",
    "FloatBorder:FloatingTermBorder",
    "FloatTitle:FloatingTermTitle",
    "FloatFooter:FloatingTermFooter",
  },
  ","
)

-- Border made of spaces, used in Neovide to pad the content by one cell.
local padding_border = {}

for _ = 1, 8 do
  padding_border[#padding_border + 1] = { " ", "FloatingTermBg" }
end

--- Update the `FloatingTermBg` highlight group, and the related border, title, and footer
--- groups, from the floating window background: lighten it for dark themes and darken it
--- (pulling toward warm tones) for light themes.
function M.update_bg()
  local bg =
    vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false }).bg or
    vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg

  if not bg then
    return
  end

  local r = bit.rshift(bit.band(bg, 0xFF0000), 16)
  local g = bit.rshift(bit.band(bg, 0x00FF00), 8)
  local b = bit.band(bg, 0x0000FF)

  -- The perceived luminance decides whether the theme is light or dark.
  local is_light   = (0.299 * r + 0.587 * g + 0.114 * b) >= 128
  local dr, dg, db = 15, 15, 15

  if is_light then
    dr, dg, db = -4, -7, -10
  end

  local function clamp(v)
    return math.max(0, math.min(255, v))
  end

  local tinted = string.format("#%02x%02x%02x", clamp(r + dr), clamp(g + dg), clamp(b + db))

  vim.api.nvim_set_hl(0, "FloatingTermBg",     { bg = tinted })
  vim.api.nvim_set_hl(0, "FloatingTermBorder", { fg = util.get_color("FloatBorder", "fg"), bg = tinted })
  vim.api.nvim_set_hl(0, "FloatingTermTitle",  { fg = util.get_color("FloatTitle", "fg"),  bg = tinted, bold = true })
  vim.api.nvim_set_hl(0, "FloatingTermFooter", { fg = util.get_color("Comment", "fg"),     bg = tinted })
  vim.api.nvim_set_hl(0, "FloatingTermAccent", { fg = util.get_color("Special", "fg"),     bg = tinted })
end

--- Return the geometry of a window centered in the editor with the given fractions of the
--- editor size. Two rows are reserved for the statusline and the cmdline.
---
--- @param width_ratio number Fraction of the editor width.
--- @param height_ratio number Fraction of the editor height.
--- @return integer width
--- @return integer height
--- @return integer row
--- @return integer col
function M.centered(width_ratio, height_ratio)
  local ui     = vim.api.nvim_list_uis()[1]
  local rows   = ui.height - 2
  local width  = math.floor(ui.width * width_ratio)
  local height = math.floor(rows * height_ratio)

  return width, height, math.floor((rows - height) / 2), math.floor((ui.width - width) / 2)
end

--- Open a floating window over a backdrop.
---
--- @param opts table Options:
---   - `buf` (integer): Buffer shown in the content window.
---   - `enter` (boolean): Whether to enter the content window (default `true`).
---   - `width`, `height`, `row`, `col` (integer): Geometry of the backdrop.
---   - `pad_v`, `pad_h` (integer): Padding between the backdrop and the content (default 1
---     and 3).
---   - `zindex` (integer): Z-index of the backdrop (default 10). The content uses the next.
---   - `style` (string|false): Style of the content window (default `"minimal"`).
---   - `winhl` (string): 'winhighlight' of the windows (default `M.winhl`).
---   - `border`, `title`, `title_pos`, `footer`, `footer_pos`: Passed to the backdrop window
---     (or to the single window in Neovide).
---   - `backdrop_buf` (integer): Backdrop buffer to reuse.
--- @return table Handle with the fields `win`, `backdrop_win`, and `backdrop_buf`.
function M.open(opts)
  M.update_bg()

  local pad_v  = opts.pad_v or 1
  local pad_h  = opts.pad_h or 3
  local zindex = opts.zindex or 10
  local enter  = opts.enter ~= false
  local winhl  = opts.winhl or M.winhl
  local float  = { backdrop_buf = opts.backdrop_buf }

  -- Options shared by the backdrop and by the single window used in Neovide.
  local frame = {
    relative   = "editor",
    row        = opts.row,
    col        = opts.col,
    width      = opts.width,
    height     = opts.height,
    border     = opts.border or "none",
    title      = opts.title,
    title_pos  = opts.title and (opts.title_pos or "center") or nil,
    footer     = opts.footer,
    footer_pos = opts.footer and (opts.footer_pos or "center") or nil,
  }

  local content = { zindex = zindex + 1 }

  if opts.style ~= false then
    content.style = "minimal"
  end

  if vim.g.neovide then
    -- Without a border, the padding is provided by the border made of spaces.
    local cfg = vim.tbl_extend(
      "force",
      frame,
      content,
      {
        width  = opts.width - 2,
        height = opts.height - 2,
        border = frame.border == "none" and padding_border or frame.border,
      }
    )

    float.win = vim.api.nvim_open_win(opts.buf, enter, cfg)
    vim.wo[float.win].winhl = winhl

    return float
  end

  if not (float.backdrop_buf and vim.api.nvim_buf_is_valid(float.backdrop_buf)) then
    float.backdrop_buf = vim.api.nvim_create_buf(false, true)
  end

  float.backdrop_win = vim.api.nvim_open_win(
    float.backdrop_buf,
    false,
    vim.tbl_extend("force", frame, { style = "minimal", focusable = false, zindex = zindex })
  )

  vim.wo[float.backdrop_win].winhl = winhl

  -- The content is inset by the padding. With a border, the backdrop area starts one cell
  -- inside it.
  local inset = frame.border ~= "none" and 1 or 0

  float.win = vim.api.nvim_open_win(
    opts.buf,
    enter,
    vim.tbl_extend(
      "force",
      content,
      {
        relative = "editor",
        row      = opts.row + inset + pad_v,
        col      = opts.col + inset + pad_h,
        width    = opts.width - 2 * pad_h,
        height   = opts.height - 2 * pad_v,
        border   = "none",
      }
    )
  )

  vim.wo[float.win].winhl = winhl

  return float
end

--- Close the windows of the float handle returned by `M.open`, keeping the backdrop buffer.
---
--- @param float table Float handle.
function M.close(float)
  for _, key in ipairs({ "win", "backdrop_win" }) do
    local win = float[key]

    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end

    float[key] = nil
  end
end

--- Set the footer of the float handle returned by `M.open`.
---
--- @param float table Float handle.
--- @param footer table Footer as a list of `{ text, hl_group }` chunks.
function M.set_footer(float, footer)
  local win = float.backdrop_win or float.win

  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_config(win, { footer = footer, footer_pos = "center" })
  end
end

return M
