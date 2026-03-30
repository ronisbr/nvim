-- Description -----------------------------------------------------------------------------
--
-- Configurations related to Julia files (*.jl).
--
-- -----------------------------------------------------------------------------------------

vim.bo.commentstring = "# %s"

-- Custom indentexpr that handles `(;` keyword argument blocks with block-style indentation
-- instead of aligning to `(`.

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
