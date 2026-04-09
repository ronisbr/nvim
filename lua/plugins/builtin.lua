-- Description -----------------------------------------------------------------------------
--
-- Configurations related to built-in plugins in Neovim.
--
-- -----------------------------------------------------------------------------------------

-- UI2 -------------------------------------------------------------------------------------

local ui2  = require("vim._core.ui2")
local msgs = require("vim._core.ui2.messages")

-- General configuraton for UI2.
vim.opt.cmdheight = 0
ui2.enable({
  enable = true,
  msg = {
    targets = {
      [""]         = "msg",
      empty        = "cmd",
      bufwrite     = "msg",
      confirm      = "cmd",
      emsg         = "pager",
      echo         = "msg",
      echomsg      = "msg",
      echoerr      = "pager",
      completion   = "cmd",
      list_cmd     = "pager",
      lua_error    = "pager",
      lua_print    = "msg",
      progress     = "pager",
      rpc_error    = "pager",
      quickfix     = "msg",
      search_cmd   = "cmd",
      search_count = "cmd",
      shell_cmd    = "pager",
      shell_err    = "pager",
      shell_out    = "pager",
      shell_ret    = "msg",
      undo         = "msg",
      verbose      = "pager",
      wildlist     = "cmd",
      wmsg         = "msg",
      typed_cmd    = "cmd",
    },
    cmd = {
      height = 0.5,
    },
    dialog = {
      height = 0.5,
    },
    msg = {
      height  = 0.3,
      timeout = 3000,
    },
    pager = {
      height = 0.5,
    },
  },
})

-- Show LSP progress messages.
vim.api.nvim_create_autocmd(
  "LspProgress",
  {
    callback = function(ev)
      local value = ev.data.params.value or {}

      -- :h LspProgress
      vim.api.nvim_echo(
        {{ value.message or "done" }},
        false,
        {
          id      = "lsp." .. ev.data.client_id,
          kind    = "progress",
          source  = "vim.lsp",
          title   = value.title,
          status  = value.kind ~= "end" and "running" or "success",
          percent = value.percentage,
        }
      )
    end,
  }
)

vim.api.nvim_create_autocmd(
  "CmdlineEnter",
  {
    callback = function()
      vim.opt.laststatus = 0
      vim.opt.cmdheight = 1
    end,
  }
)

vim.api.nvim_create_autocmd(
  "CmdlineLeave",
  {
    callback = function()
      vim.opt.laststatus = 3
      vim.opt.cmdheight = 0
    end,
  }
)

-- Override the default position of messages to be at the top right corner of the editor.
local orig_set_pos = msgs.set_pos
msgs.set_pos = function(tgt)
  orig_set_pos(tgt)

  if (tgt == "msg" or tgt == nil) and vim.api.nvim_win_is_valid(ui2.wins.msg) then
    pcall(
      vim.api.nvim_win_set_config,
      ui2.wins.msg,
      {
        relative = "editor",
        anchor   = "NE",
        row      = 0,
        col      = vim.o.columns - 1,
        border   = "rounded",
      }
    )
  end
end

-- undotree --------------------------------------------------------------------------------

vim.cmd("packadd nvim.undotree")

vim.api.nvim_create_user_command(
  "Undotree",
  function()
    require("undotree").open({ command = "45vnew" })
  end,
  {}
)

