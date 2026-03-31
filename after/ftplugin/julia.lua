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
_G._julia_formatexpr = function()
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

vim.opt_local.formatexpr = "v:lua._julia_formatexpr()"

--- Find the line number of the `(;` that opens the block closed by `)` at `lnum`.
---
--- Walk backwards from `lnum`, counting parentheses depth. When the matching `(` is found,
--- check if it is followed by `;`. If so, return that line number; otherwise return nil.
---
--- @param lnum integer Line number of the closing `)`.
--- @return integer|nil # Line number of the matching `(;`, or nil if not a `(;` block.
local function find_matching_open_paren(lnum)
    local depth = 1
    local search_lnum = lnum - 1

    while search_lnum >= 1 and depth > 0 do
        local line = vim.fn.getline(search_lnum)

        for i = #line, 1, -1 do
            local ch = line:sub(i, i)

            if ch == ')' then
                depth = depth + 1
            elseif ch == '(' then
                depth = depth - 1

                if depth == 0 then
                    local after = line:sub(i + 1):match('^%s*;')
                    if after then
                        return search_lnum
                    end

                    return nil
                end
            end
        end

        search_lnum = search_lnum - 1
    end
    return nil
end

--- Check if `lnum` is inside a `(;` keyword argument block.
---
--- Walk backwards from `lnum`, tracking parenthesis depth. When an unmatched `(` is found,
--- check if it is followed by `;`. If so, `lnum` is inside a `(;` block and the opening
--- line number is returned; otherwise return nil.
---
--- @param lnum integer Line number to check.
--- @return integer|nil # Line number of the enclosing `(;`, or nil if not inside one.
local function find_enclosing_semi_block(lnum)
    local depth = 0
    local search_lnum = lnum - 1

    while search_lnum >= 1 do
        local line = vim.fn.getline(search_lnum)

        for i = #line, 1, -1 do
            local ch = line:sub(i, i)

            if ch == ')' then
                depth = depth + 1
            elseif ch == '(' then
                if depth == 0 then
                    local after = line:sub(i + 1):match('^%s*;')

                    if after then
                        return search_lnum
                    end

                    return nil
                end
                depth = depth - 1
            end
        end

        search_lnum = search_lnum - 1
    end
    return nil
end

--- Custom indent function for Julia that wraps tree-sitter indentation.
---
--- Intercepts lines inside `(;` keyword argument blocks and returns block-style indentation
--- (one `shiftwidth` relative to the opening line) instead of tree-sitter's default
--- behavior of aligning to the `(` column. All other cases fall through to
--- `nvim_treesitter#indent()`.
---
--- @return integer # The indentation level (in spaces) for the current line (`v:lnum`).
local function julia_indent()
    local lnum = vim.v.lnum
    if lnum <= 1 then
        return 0
    end

    local sw = vim.fn.shiftwidth()

    -- Check if previous non-blank line ends with `(;`.
    local prev_lnum = vim.fn.prevnonblank(lnum - 1)
    local prev_line = vim.fn.getline(prev_lnum)

    if prev_line:match('%(%s*;%s*$') then
        return vim.fn.indent(prev_lnum) + sw
    end

    local cur_line = vim.fn.getline(lnum)
    local trimmed = cur_line:match('^%s*(.)')

    -- Check if current line is `)` closing a `(;` block.
    if trimmed == ')' then
        local found = find_matching_open_paren(lnum)
        if found then
            return vim.fn.indent(found)
        end
    end

    -- Check if we're inside a `(;` block.
    local inside = find_enclosing_semi_block(lnum)
    if inside then
        return vim.fn.indent(inside) + sw
    end

    -- Fall through to tree-sitter indent.
    return require('nvim-treesitter').indentexpr()
end

_G._julia_indent = julia_indent

-- nvim-treesitter sets indentexpr via a FileType autocommand that fires after
-- after/ftplugin. Use vim.schedule to set ours after tree-sitter is done.
local bufnr = vim.api.nvim_get_current_buf()
vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
        vim.bo[bufnr].indentexpr = "v:lua._julia_indent()"
    end
end)
