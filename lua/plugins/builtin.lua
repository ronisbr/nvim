-- Description -----------------------------------------------------------------------------
--
-- Configurations related to built-in plugins in Neovim.
--
-- -----------------------------------------------------------------------------------------

-- CmdAtom ---------------------------------------------------------------------------------

-- ................................................................................... teste
-- ................................................................................ -- teste

-- Track the last 20 atoms.
local atom_ring = {} ---@type vim.event.cmdatom.data[]

vim.api.nvim_create_autocmd(
  "CmdAtom",
  {
    callback = function(ev)
      -- Skip this mapping itself, and cmdwin edits.
      if ev.data.lhs ~= " " and vim.fn.getcmdwintype() == "" then
        atom_ring[#atom_ring + 1] = ev.data
        if #atom_ring > 20 then
          table.remove(atom_ring, 1)
        end
      end
    end,
  }
)

-- `[count]\` shows a cmdwin where the user can edit/save the last [count] atoms as a
-- "macro". \ (no count) replays it.
vim.keymap.set(
  "n",
  "\\",
  function()
    local count = vim.v.count
    -- CmdAtom is deferred; schedule it so pending events land in the ring first.
    vim.schedule(
      function()
        count = math.min(count, #atom_ring)

        if count == 0 then -- Replay the saved macro.
          for _, step in ipairs(vim.g.atom_macro or {}) do
            vim.api.nvim_feedkeys(vim.keycode(step.keys or step.lhs), step.keys and "n" or "m", false)
          end
          return
        end

        local parts = {}

        for i = #atom_ring - count + 1, #atom_ring do
          local a = atom_ring[i]
          local keys = a.keys or ("%s%s"):format(a.count or "", a.lhs)
          local field = a.keys and "keys" or "lhs"
          parts[#parts + 1] = ("{%s=%q},"):format(field, vim.fn.keytrans(keys))
        end

        local cmd = ("lua vim.g.atom_macro = { %s }"):format(table.concat(parts, " "))

        -- Draft it on the cmdline; CTRL-F opens the cmdwin to edit it.
        vim.api.nvim_feedkeys((":%s%s"):format(cmd, vim.keycode("<C-f>")), "n", false)
      end
    )
  end
)

-- UI2 -------------------------------------------------------------------------------------

local ui2  = require("vim._core.ui2")
local msgs = require("vim._core.ui2.messages")

-- General configuraton for UI2.
vim.opt.cmdheight = 1
ui2.enable({
  enable = true,
  msg = {
    -- Keys are message kinds (`:h ui-messages`), triggers (`typed_cmd`) and Lua patterns
    -- matched against the message ID. Note that the pattern match runs before the kind
    -- lookup, so keys must not match unrelated IDs (an empty key would match every ID).
    -- Buffer write, completion, and LSP messages are all "progress" messages now.
    targets = {
      default      = "msg",
      empty        = "cmd",
      confirm      = "cmd",
      emsg         = "pager",
      echo         = "msg",
      echomsg      = "msg",
      echoerr      = "pager",
      completion   = "cmd",
      list_cmd     = "pager",
      lua_error    = "pager",
      lua_print    = "msg",
      progress     = "msg",
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
    dialog = {
      height = 0.5,
    },
    msg = {
      height  = 0.3,
    },
    pager = {
      height = 0.5,
    },
  },
})

-- Messages stay 3 s in the message window, and <CR> right after a `:` command that showed a
-- collapsed message opens the pager (`g<` works at any time).
vim.opt.messagesopt:append({ "timeout:3000", "pager:<CR>" })

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
