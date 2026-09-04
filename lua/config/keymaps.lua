-- Description -----------------------------------------------------------------------------
--
-- Keymaps configurations.
--
-- -----------------------------------------------------------------------------------------

function map(mode, lhs, rhs)
  return vim.keymap.set(mode, lhs, rhs, { silent = true })
end

function map(mode, lhs, rhs, desc)
  return vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

function rmap(mode, lhs, rhs, desc)
  return vim.keymap.set(mode, lhs, rhs, { desc = desc, remap = true, silent = true })
end

function emap(mode, lhs, rhs, desc)
  return vim.keymap.set(mode, lhs, rhs, { desc = desc, expr = true, silent = true })
end

map("n", "<Esc>", "<Esc><Cmd>noh<CR>")

-- Arrows ----------------------------------------------------------------------------------

map({"n", "v"}, "<Up>", "gk")
map({"n", "v"}, "<Down>", "gj")

map("i", "<Up>", "<C-o>gk")
map("i", "<Down>", "<C-o>gj")

-- Buffers ---------------------------------------------------------------------------------

map("n", "[b", ":bprev<CR>", "Previous Buffer")
map("n", "]b", ":bnext<CR>", "Next Buffer")
map("n", "<Leader>bw", "<Cmd>%bd|e#|bd#<CR>", "Close All Buffers Except Current")

-- Tabs ------------------------------------------------------------------------------------

map("n", "[t", ":tabprevious<CR>", "Previous Tab")
map("n", "]t", ":tabnext<CR>", "Next Tab")

-- Text Manipulation -----------------------------------------------------------------------

-- Return an expression mapping right-hand side that runs `keys` through the `g@` operator
-- (via 'operatorfunc'), making the mapping repeatable with `.`. `motion` is appended to
-- `g@`: use "l" for normal mode mappings and "" for visual mode ones, where the selection
-- provides the range.
local function dot_repeatable(motion, keys)
  local feed = vim.api.nvim_replace_termcodes(keys, true, false, true)

  -- `:normal!` is used instead of `nvim_feedkeys(feed, "nx", false)` because the "x" flag
  -- flushes the typeahead, which can interfere with the native multicursor cascade
  -- replaying the mapping at the other cursors.
  local function opfunc()
    vim.cmd.normal({ args = { feed }, bang = true })
  end

  return function()
    -- `{Visual}Q` also places an extra cursor at the main cursor position. Since the main
    -- run edits the line, the extra cursor's extmark drifts and the multicursor cascade
    -- no longer recognizes it as coincident, replaying the operator a second time on the
    -- same line (Neovim also does this with builtin operators like `>>`). Remove the
    -- coincident cursor: the main cursor already covers that spot.
    local ns = vim.api.nvim_create_namespace("nvim.multicursor")
    local pos = vim.api.nvim_win_get_cursor(0)

    for _, m in ipairs(vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})) do
      if m[2] == pos[1] - 1 and m[3] == pos[2] then
        vim.api.nvim_buf_del_extmark(0, ns, m[1])
      end
    end

    -- 'operatorfunc' accepts a Lua function directly (Neovim v0.13).
    vim.o.operatorfunc = opfunc
    return "g@" .. motion
  end
end

emap(
  "n",
  "<Leader>ta",
  dot_repeatable(
    "l",
    "<Cmd>set lazyredraw<CR>" ..
    "<Cmd>set formatoptions-=ro<CR>" ..
    "mavy`]a<CR><Esc><Cmd>right<CR>k93PDd92|j0whv$hykP`]lDjdd`a" ..
    "<Cmd>set formatoptions+=ro<CR>" ..
    "<Cmd>set nolazyredraw<CR>"
  ),
  "Left Align with Character Under the Cursor"
)

-- The pattern is yanked with ``[v`]y` instead of `y` because `g@` leaves visual mode
-- before calling 'operatorfunc'; the `[ and `] marks also cover the repeated range when
-- the mapping is replayed with `.`.
emap(
  "v",
  "<Leader>ta",
  dot_repeatable(
    "",
    "`[v`]yma<Cmd>set formatoptions-=ro<CR>" ..
    "<Cmd>set lazyredraw<CR>" ..
    "`]a<CR><Esc><Cmd>right<CR>k93pDd92|j0whv$hykP`]lDjdd`a" ..
    "<Cmd>set formatoptions+=ro<CR>" ..
    "<Cmd>set nolazyredraw<CR>"
  ),
  "Left Align with Selected Pattern"
)

map(
  "n",
  "<Leader>tf",
  "<Cmd>set lazyredraw<CR>" ..
  "vy93pDd92|" ..
  "<Cmd>set nolazyredraw<CR>",
  "Fill with Character Under the Cursor"
)

map(
  "v",
  "<Leader>tf",
  "y" ..
  "<Cmd>set lazyredraw<CR>" ..
  "93pDd92|" ..
  "<Cmd>set nolazyredraw<CR>",
  "Fill with Selected Pattern"
)

-- Create a text block given the following input:
--
--     Current line: Fill pattern.
--     Next line: Text to be centered in the block.
map(
  "n",
  "<Leader>tb",
  "<Cmd>set lazyredraw<CR>" ..
  "<Cmd>set formatoptions-=ro<CR>" ..
  "0v$hy93P\"_D\"_d92|j0<Cmd>center<CR>0R<C-R>0<Esc>o<Esc>P<Cmd>right<CR>khjllv$hykpkyyjpjdd0" ..
  "<Cmd>set formatoptions+=ro<CR>" ..
  "<Cmd>set nolazyredraw<CR>",
  "Convert to Block"
)

-- AI Coding Tools ---------------------------------------------------------------------------

map(
  "n",
  "<Leader>ac",
  function()
    local file = vim.fn.expand("%:p")
    local line = vim.fn.line(".")
    local ref = file .. ":" .. line
    vim.fn.setreg("+", ref)
    vim.notify("Copied: " .. ref)
  end,
  "Copy File:Line Reference to Clipboard"
)

-- Placeholders <++> -----------------------------------------------------------------------

map("n", "<C-j>", "/<++><CR>v3lc", "Change Next Placeholder")
map("i", "<C-j>", "<Esc>/<++><CR>v3lc", "Change Next Placeholder")
