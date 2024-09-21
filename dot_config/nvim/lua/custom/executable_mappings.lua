local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Add breakpoint at line"
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Run or continue the debugger"
    }
  },
}

M.codeium = {
  plugin = true,
  n = {
    ["<leader>ac"] = {
      function()
        return vim.fn['codeium#Accept']()
      end,
      "Accept codeium suggestion"
    }
  }
}

M.rust = {
  plugin = true,
  n = {
    ["<leader>rc"] = {
      function()
        vim.cmd.RustLsp('openCargo')
      end,
      "Open Cargo.toml"
    },
    ["<leader>rh"] = {
      function()
        vim.cmd.RustLsp { 'hover', 'actions' }
      end,
      "hover actions"
    },

    ["<leader>ra"] = {
      function()
        vim.cmd.RustLsp('codeAction')
      end,
      "code action"
    }
  }
}

M.context = {
  plugin = true,
  n = {
    ["<leader>[c"] = {
      function()
        return require('treesitter-context').go_to_context(vim.v.count1)
      end,
      "jump to context"
    }
  }
}

return M
