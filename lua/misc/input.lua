-- Description -----------------------------------------------------------------------------
--
-- Custom implementation of vim.ui.input using floating windows.
--
-- -----------------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------------------
--                                       Constants                                        --
--------------------------------------------------------------------------------------------

local inp_pad_v = 1
local inp_pad_h = 3

--------------------------------------------------------------------------------------------
--                                       Functions                                        --
--------------------------------------------------------------------------------------------

--- Compute and set the "InputBg" highlight group to a slightly lighter or darker shade
--- of the Normal background, depending on the current luminance.
local function update_input_bg()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local bg = normal.bg

  if not bg then return end

  local r = bit.rshift(bit.band(bg, 0xFF0000), 16)
  local g = bit.rshift(bit.band(bg, 0x00FF00), 8)
  local b = bit.band(bg, 0x0000FF)

  local luminance = 0.299 * r + 0.587 * g + 0.114 * b
  local offset = luminance < 128 and 15 or -10

  r = math.max(0, math.min(255, r + offset))
  g = math.max(0, math.min(255, g + offset))
  b = math.max(0, math.min(255, b + offset))

  vim.api.nvim_set_hl(0, "InputBg", { bg = string.format("#%02x%02x%02x", r, g, b) })
end

--- Open a floating input prompt and call on_confirm with the entered text.
-- The prompt is rendered as a centered backdrop window with a padded input window inside.
-- @param opts table: Options forwarded from vim.ui.input (fields: prompt, default).
-- @param on_confirm function: Callback invoked with the input string, or nil if aborted.
local function wininput(opts, on_confirm)
  -- Create a "prompt" buffer that will be deleted once focus is lost.
  local buf = vim.api.nvim_create_buf(false, false)
  vim.bo[buf].buftype    = "prompt"
  vim.bo[buf].bufhidden  = "wipe"
  vim.bo[buf].textwidth  = 0
  vim.bo[buf].wrapmargin = 0

  local prompt = opts.prompt or ""
  local default_text = opts.default or ""

  -- Defer the on_confirm callback so that it is executed after the prompt window is
  -- closed.
  local deferred_callback = function(input)
    vim.defer_fn(function()
      on_confirm(input)
    end, 10)
  end

  -- Set the prompt and callback (CR) for the prompt buffer.
  vim.fn.prompt_setprompt(buf, prompt)
  vim.fn.prompt_setcallback(buf, deferred_callback)

  -- Set keymaps: CR to confirm and exit, ESC in normal mode to abort.
  vim.keymap.set(
    { "i", "n" },
    "<CR>",
    "<CR><Esc>:close!<CR>:stopinsert<CR>",
    {
      silent = true,
      buffer = buf
    }
  )

  vim.keymap.set(
    "n",
    "<Esc>",
    "<Cmd>close!<CR>",
    {
      silent = true,
      buffer = buf
    }
  )

  vim.keymap.set(
    "n",
    "q",
    function()
      return vim.fn.mode() == "n" and "ZQ" or "<esc>"
    end,
    {
      expr   = true,
      silent = true,
      buffer = buf
    }
  )

  local input_width     = math.floor((vim.o.columns) * 0.7)
  local backdrop_width  = input_width + 2 * inp_pad_h
  local backdrop_height = 1 + 2 * inp_pad_v
  local backdrop_col    = math.floor((vim.o.columns - backdrop_width) / 2)
  local backdrop_row    = 5

  update_input_bg()

  -- Open the backdrop window.
  local backdrop_buf = vim.api.nvim_create_buf(false, true)
  local backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, {
    relative  = "editor",
    row       = backdrop_row,
    col       = backdrop_col,
    width     = backdrop_width,
    height    = backdrop_height,
    focusable = false,
    style     = "minimal",
    border    = "none",
    zindex    = 49,
  })

  vim.api.nvim_set_option_value("winhl", "Normal:InputBg", { win = backdrop_win })

  -- Open the input window inside the backdrop with padding.
  local win = vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    row       = backdrop_row + inp_pad_v,
    col       = backdrop_col + inp_pad_h,
    width     = input_width,
    height    = 1,
    focusable = true,
    style     = "minimal",
    border    = "none",
    zindex    = 50,
  })

  vim.api.nvim_set_option_value("winhl", "Normal:InputBg,Search:None", { win = win })
  vim.api.nvim_set_option_value("wrap", false, { win = win })

  -- Close the backdrop when the input window closes.
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern  = tostring(win),
    once     = true,
    callback = function()
      if vim.api.nvim_win_is_valid(backdrop_win) then
        vim.api.nvim_win_close(backdrop_win, true)
      end
    end,
  })

  vim.cmd("startinsert")

  -- Set the default text (needs to be deferred after the prompt is drawn).
  vim.defer_fn(
    function()
      vim.api.nvim_buf_set_text(buf, 0, #prompt, 0, #prompt, { default_text })

      -- NOTE: The bang goes to the end of line.
      vim.cmd("startinsert!")
    end,
    5
  )
end

--- Override vim.ui.input (telescope rename/create, LSP rename, etc.).
function M.setup()
  vim.ui.input = function(opts, on_confirm)
    wininput(opts, on_confirm)
  end
end

return M
