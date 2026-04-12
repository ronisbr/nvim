-- Description -----------------------------------------------------------------------------
--
-- General options for Neovim.
--
-- -----------------------------------------------------------------------------------------

vim.opt.autoread = true
vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.scrolloff = 10
vim.opt.shiftwidth = 4
vim.opt.smartcase = true
vim.opt.spelllang = "en,pt"
vim.opt.tabstop = 4
vim.opt.textwidth = 92

if not vim.g.vscode then
  vim.opt.colorcolumn = "93"
  vim.opt.cursorline = true
  vim.opt.inccommand = "nosplit"
  vim.opt.lazyredraw = false
  vim.opt.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
  vim.opt.mouse = 'a'
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.ruler = false
  vim.opt.shortmess = vim.opt.shortmess + { c = true, q = true }
  vim.opt.showcmd = false
  vim.opt.showmode = false
  vim.opt.signcolumn = "yes"
  vim.opt.splitbelow = true
  vim.opt.splitright = true
  vim.opt.undofile = true
  vim.opt.updatetime = 250
  vim.opt.virtualedit = "block"
  vim.opt.winborder = "rounded"
end

-- Neovide ---------------------------------------------------------------------------------

if vim.g.neovide then
  -- vim.o.guifont = "JetBrains Mono,Symbols Nerd Font Mono:h15"
  vim.o.guifont = "Monaco Nerd Font:h15"
  vim.o.linespace = -1

  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_floating_blur_amount_x = 6.0
  vim.g.neovide_floating_blur_amount_y = 6.0
  vim.g.neovide_floating_corner_radius = 0.4
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_left = 10
  vim.g.neovide_padding_right = 10
  vim.g.neovide_padding_top = 10
  vim.g.neovide_scroll_animation_length = 0.1

  -- We must disable shadows until this bug is fixed:
  --
  --     https://github.com/neovide/neovide/issues/2931
  --
  vim.g.neovide_floating_shadow = false
  -- vim.g.neovide_floating_z_height = 10
  -- vim.g.neovide_light_angle_degrees = 0
  -- vim.g.neovide_light_radius = 5

  -- Fix pasting using `CMD+v` on macOS. Otherwise, we will not be able to paste to the
  -- terminal using `CMD+v` on Neovide. For more information, see:
  --
  --    https://github.com/neovide/neovide/issues/1263
  vim.keymap.set(
    {'n', 'v', 's', 'x', 'o', 'i', 'l', 'c', 't'},
    '<D-v>',
    function()
      vim.api.nvim_paste(vim.fn.getreg('+'), true, -1)
    end,
    {
      noremap = true,
      silent = true
    }
  )
end

-- Dictionaries ----------------------------------------------------------------------------

-- Download missing spell files from the Vim runtime repository.
do
  local spell_dir = vim.fn.stdpath("data") .. "/site/spell/"
  local base_url = "https://ftp.nluug.nl/pub/vim/runtime/spell/"

  -- Download a spell file from the Vim runtime repository into `spell_dir`. The file is
  -- first saved to a `.tmp` path and atomically renamed on success to avoid leaving a
  -- truncated file that would prevent future retries.
  local function download(file)
    vim.notify("Downloading spell file: " .. file, vim.log.levels.INFO)
    vim.fn.mkdir(spell_dir, "p")
    local tmp = spell_dir .. file .. ".tmp"

    vim.system(
      { "curl", "-fsSL", "-o", tmp, base_url .. file },
      {},
      vim.schedule_wrap(function(result)
        if result.code == 0 then
          vim.uv.fs_rename(tmp, spell_dir .. file, function()
            vim.schedule(function()
              vim.notify("Spell file downloaded: " .. file, vim.log.levels.INFO)
              vim.cmd("silent! edit")
            end)
          end)
        else
          vim.uv.fs_unlink(tmp, function() end)
          vim.notify("Failed to download spell file: " .. file, vim.log.levels.ERROR)
        end
      end)
    )
  end

  -- Check whether the UTF-8 spell file for `lang` exists and is non-empty. Uses only the
  -- two-letter language prefix (e.g. "en" for "en_us") since that is the filename
  -- convention used by the Vim runtime repository. Downloads the file if it is missing or
  -- zero-size.
  local function ensure_dict(lang)
    local file = lang:sub(1, 2) .. ".utf-8.spl"
    local path = spell_dir .. file
    local stat = vim.uv.fs_stat(path)
    if not stat or stat.size == 0 then
      download(file)
    end
  end

  for _, lang in ipairs(vim.split(vim.o.spelllang, ",")) do
    ensure_dict(lang)
  end

end
