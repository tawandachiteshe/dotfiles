local dap = require('dap')

-- ╭──────────────────────────────────────────────────────────╮
-- │ Adapters                                                 │
-- ╰──────────────────────────────────────────────────────────╯

-- VSCODE JS (Node/Chrome/Terminal/Jest)
require("dap-vscode-js").setup({
  debugger_path = vim.fn.stdpath('data') .. "/lazy/vscode-js-debug",
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
  -- debugger_cmd = { "js-debug-adapter" }
})

-- HOME_PATH = os.getenv("HOME") .. "/"
-- MASON_PATH = HOME_PATH .. ".local/share/nvim/mason/packages/"
-- local codelldb_path = MASON_PATH .. "codelldb/extension/adapter/codelldb"
-- local liblldb_path = MASON_PATH .. "codelldb/extension/lldb/lib/liblldb.so"
-- --
-- local opts = {
--   -- ... other configs
--   dap = {
--     adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
--   }
-- }
-- -- Normal setup
-- require('rust-tools').setup(opts)

--
dap.adapters.delve = {
  type = 'server',
  port = '${port}',
  executable = {
    command = 'dlv',
    args = { 'dap', '-l', '127.0.0.1:${port}' },
    -- add this if on windows, otherwise server won't open successfully
    -- detached = false
  }
}

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {
    type = "delve",
    name = "Debug",
    request = "launch",
    program = "${file}"
  },
  {
    type = "delve",
    name = "Debug test", -- configuration for debugging test files
    request = "launch",
    mode = "test",
    program = "${file}"
  },
  -- works with go.mod packages and sub packages
  {
    type = "delve",
    name = "Debug test (go.mod)",
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}"
  }
}

dap.adapters.codelldb = {
  type = 'server',
  host = '127.0.0.1',
  port = "${port}",
  executable = {
    command = "codelldb",
    args = { "--port", "${port}" },
  },

}


local c_cpp_exs = { "c", "cpp", "cc", "cxx", "c++" }

for _, ex in ipairs(c_cpp_exs) do
  dap.configurations[ex] = {
    {
      name = "Launch file",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
    },
  }
end

-- ╭──────────────────────────────────────────────────────────╮
-- │ Configurations                                           │
-- ╰──────────────────────────────────────────────────────────╯
local exts = {
  "javascript",
  "typescript",
  "javascriptreact",
  "typescriptreact",
  "vue",
  "svelte",
}

for _, ext in ipairs(exts) do
  dap.configurations[ext] = {
    {
      type = "pwa-chrome",
      request = "launch",
      name = "Launch Chrome with \"localhost\"",
      url = function()
        local co = coroutine.running()
        return coroutine.create(function()
          vim.ui.input({ prompt = 'Enter URL: ', default = 'http://localhost:3000' }, function(url)
            if url == nil or url == '' then
              return
            else
              coroutine.resume(co, url)
            end
          end)
        end)
      end,
      webRoot = vim.fn.getcwd(),
      protocol = 'inspector',
      sourceMaps = true,
      userDataDir = false,
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      }
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "yarn start:debug",
      cwd = "${workspaceFolder}",
      runtimeExecutable = "yarn",
      runtimeArgs = {
        "start:dev"
      },
      internalConsoleOptions = "openOnSessionStart",
      sourceMaps = true,
      protocol = "inspector",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
      console = "integratedTerminal",
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
      port = 9229,
      envFile = "${workspaceFolder}/.env",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug Nest Framework",
      sourceMaps = true,
      args = {
        "${workspaceFolder}/src/main.ts"
      },
      runtimeArgs = {
        "--nolazy",
        "-r",
        "ts-node/register",
        "-r",
        "tsconfig-paths/register" },
      protocol = "inspector",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
      envFile = "${workspaceFolder}/.env",

    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Current File (pwa-node)",
      cwd = vim.fn.getcwd(),
      args = { "${file}" },
      sourceMaps = true,
      protocol = "inspector",
      runtimeExecutable = "npm",
      runtimeArgs = {
        "run-script", "dev"
      },
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      }

    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Current File (pwa-node with ts-node)",
      cwd = vim.fn.getcwd(),
      runtimeArgs = { "--loader", "ts-node/esm" },
      runtimeExecutable = "node",
      args = { "${file}" },
      sourceMaps = true,
      protocol = "inspector",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Current File (pwa-node with deno)",
      cwd = vim.fn.getcwd(),
      runtimeArgs = { "run", "--inspect-brk", "--allow-all", "${file}" },
      runtimeExecutable = "deno",
      attachSimplePort = 9229,
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Test Current File (pwa-node with jest)",
      cwd = vim.fn.getcwd(),
      runtimeArgs = { "${workspaceFolder}/node_modules/.bin/jest" },
      runtimeExecutable = "node",
      args = { "${file}", "--coverage", "false" },
      rootPath = "${workspaceFolder}",
      sourceMaps = true,
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Test Current File (pwa-node with vitest)",
      cwd = vim.fn.getcwd(),
      program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
      args = { "--inspect-brk", "--threads", "false", "run", "${file}" },
      autoAttachChildProcesses = true,
      smartStep = true,
      console = "integratedTerminal",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Test Current File (pwa-node with deno)",
      cwd = vim.fn.getcwd(),
      runtimeArgs = { "test", "--inspect-brk", "--allow-all", "${file}" },
      runtimeExecutable = "deno",
      attachSimplePort = 9229,
    },
    {
      type = "pwa-chrome",
      request = "attach",
      name = "Attach Program (pwa-chrome, select port)",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = 'inspector',
      port = function()
        return vim.fn.input("Select port: ", 9222)
      end,
      webRoot = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach Program (pwa-node, select pid)",
      cwd = vim.fn.getcwd(),
      processId = require "dap.utils".pick_process,
      skipFiles = { "<node_internals>/**" },
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach debugger without any",
      cwd = "${workspaceFolder}/src",
      sourceMaps = true,
      resolveSourceMapLocations = { "${workspaceFolder}/**",
        "!**/node_modules/**" },
      skipFiles = { "<node_internals>/**" },
    }
  }
end
