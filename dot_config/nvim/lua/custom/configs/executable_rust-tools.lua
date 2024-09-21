local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities


local options = {
  server = {
    on_attach = on_attach,
    capabilities = capabilities,
  },
  dap = {
    adapter = {
      type = "executable",
      command = "codelldb",
      name = "rt_lldb",
    },
  },
}

return options
