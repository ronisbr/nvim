-- Description -----------------------------------------------------------------------------
--
-- Configurations related to Julia files (*.jl).
--
-- -----------------------------------------------------------------------------------------

vim.bo.commentstring = "# %s"

--- Re-wrap a markdown-style bullet paragraph to fit within `tw` columns.
---
--- If the first line starts with a bullet marker (`-`, `*`, or `+`), flatten all lines into
--- a single string, then greedily wrap words at `tw` columns. Continuation lines are indented
--- by `shiftwidth` spaces. Return `nil` when the paragraph is not a bullet item so the caller
--- can fall back to Vim's internal formatter.
---
--- @param lines string[] The paragraph lines to format.
--- @param tw integer Target text width in columns.
--- @return string[]|nil # Wrapped lines, or nil if the paragraph is not a bullet item.
local function _julia_format_bullet(lines, tw)
  if not lines[1]:match("^%s*[-*+]%s") then return nil end

  -- Flatten the paragraph into a single string.
  local parts = {}
  for i, line in ipairs(lines) do
    local text = i == 1 and line or (line:match("^%s*(.-)%s*$") or "")
    if text ~= "" then table.insert(parts, text) end
  end

  local all_text = table.concat(parts, " "):gsub("%s+", " ")
  local cont     = string.rep(" ", vim.fn.shiftwidth())  -- continuation indent
  local result   = {}
  local current  = ""

  for word in all_text:gmatch("%S+") do
    if current == "" then
      current = word
    elseif #current + 1 + #word <= tw then
      current = current .. " " .. word
    else
      table.insert(result, current)
      current = cont .. word
    end
  end

  if current ~= "" then table.insert(result, current) end
  return result
end

--- Format expression for Julia buffers (`formatexpr`).
---
--- Invoked by Vim's `gq` operator. Delegates bullet paragraphs to `_julia_format_bullet`,
--- falls back to LSP range formatting when available, and finally to Vim's internal formatter.
---
--- @return integer # 0 when formatting was handled, 1 to fall back to Vim's default.
local function julia_formatexpr()
  local start_lnum = vim.v.lnum
  local count      = vim.v.count
  local tw         = vim.bo.textwidth > 0 and vim.bo.textwidth or 79
  local lines      = vim.api.nvim_buf_get_lines(0, start_lnum - 1, start_lnum + count - 1, false)
  local result     = _julia_format_bullet(lines, tw)

  if result then
    vim.api.nvim_buf_set_lines(0, start_lnum - 1, start_lnum + count - 1, false, result)
    return 0
  end

  -- Fall back to LSP range formatting if available.
  local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/rangeFormatting" })
  if #clients > 0 then
    local end_lnum = start_lnum + count - 1
    vim.lsp.buf.format({
      range = {
        start  = { start_lnum, 0 },
        ["end"] = { end_lnum, #vim.fn.getline(end_lnum) },
      },
    })
    return 0
  end

  return 1  -- fall back to Vim's internal formatter.
end

vim.bo.formatexpr = julia_formatexpr
