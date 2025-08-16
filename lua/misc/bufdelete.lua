-- Description -----------------------------------------------------------------------------
--
-- Function to delete a buffer without changing the layout.
--
-- -----------------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------------------
--                                   Private Functions                                    --
--------------------------------------------------------------------------------------------

--- Delete a buffer without changing the window layout.
-- If no buffer number is provided, deletes the current buffer.
-- Automatically switches windows displaying the buffer to a fallback buffer.
-- @param bufnr (number|nil) Buffer number to delete (optional).
local function bufdelete(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return nil end

  -- Collect all windows currently showing this buffer
  local wins = vim.fn.getbufinfo(bufnr)[1] and vim.fn.getbufinfo(bufnr)[1].windows or {}

  -- Choose a fallback buffer considering the following order:
  --
  --   1. The alternate buffer (#) if valid and listed.
  --   2. Any other listed buffer.
  --   3. Create a scratch buffer.

  local function pick_fallback()
    local alt = vim.fn.bufnr("#")

    -- Pick the alternate buffer if it is valid and listed.
    if (
      alt > 0 and
      vim.api.nvim_buf_is_valid(alt) and
      vim.bo[alt].buflisted and
      alt ~= bufnr
    ) then
      return alt
    end

    -- Pick any other buffer considering the current order.
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if b ~= bufnr and vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted then
        return b
      end
    end

    -- Create an unlisted scratch buffer if nothing else.
    local scratch = vim.api.nvim_create_buf(false, true)

    -- Make it look like a fresh empty buffer
    vim.bo[scratch].buftype   = ""
    vim.bo[scratch].swapfile  = false
    vim.bo[scratch].bufhidden = "hide"

    return scratch
  end

  local fallback = pick_fallback()

  -- For every window that displays the buffer, set it to the fallback first.
  for _, w in ipairs(wins) do
    if vim.api.nvim_win_is_valid(w) then
      vim.api.nvim_win_set_buf(w, fallback)
    end
  end

  -- Now it is safe to wipe/delete the target buffer without collapsing windows.
  -- NOTE: bwipeout to fully remove it; use bdelete if you just want it hidden.
  pcall(vim.cmd, ("silent! bwipeout %d"):format(bufnr))
end

--------------------------------------------------------------------------------------------
--                                    Public Functions                                    --
--------------------------------------------------------------------------------------------

function M.setup()
  vim.keymap.set(
    "n",
    "<Leader>bd",
    bufdelete,
    {
      desc   = "Delete Buffer (Keep Layout)",
      silent = true,
    }
  )
end

return M

-- vim:ts=2:sts=2:sw=2:et
