-- Modern LSP Configuration using vim.lsp.config and LspAttach
-- This file replaces the traditional nvim-lspconfig approach

local M = {}

-- Helper function to create augroup
local function augroup(name)
  return vim.api.nvim_create_augroup("lsp_" .. name, { clear = true })
end

-- ============================================================================
-- Server Configurations
-- ============================================================================

-- Clangd (C/C++)
vim.lsp.config('clangd', {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    "--query-driver=/usr/bin/clang++",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = {
    "Makefile",
    "configure.ac",
    "configure.in",
    "config.h.in",
    "meson.build",
    "meson_options.txt",
    "build.ninja",
    "compile_commands.json",
    "compile_flags.txt",
    ".git",
  },
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
    },
    offsetEncoding = { "utf-16" },
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
})

-- Gopls (Go)
vim.lsp.config('gopls', {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      gofumpt = true,
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      semanticTokens = true,
    },
  },
})

-- Lua Language Server
vim.lsp.config('lua_ls', {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- Pyright (Python)
vim.lsp.config('pyright', {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    "pyrightconfig.json",
    ".git",
  },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- ElixirLS (Elixir)
vim.lsp.config('elixirls', {
  cmd = { "elixir-ls" },
  filetypes = { "elixir", "eelixir", "heex", "surface" },
  root_markers = { "mix.exs", ".git" },
  settings = {
    elixirLS = {
      dialyzerEnabled = true,
      fetchDeps = false,
      enableTestLenses = false,
      suggestSpecs = false,
    },
  },
})

-- Rust Analyzer
-- Note: rust-analyzer is handled by rustaceanvim plugin (lua/plugins/rust.lua)
-- No manual configuration needed here

-- ============================================================================
-- LspAttach Autocmd - Centralized buffer-local setup
-- ============================================================================

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("config"),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Buffer local mappings
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- Keep some custom keymaps that don't conflict with defaults
    map("n", "<leader>cl", "<cmd>LspInfo<cr>", "Lsp Info")
    map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
    map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")

    -- Note: Modern Neovim provides these by default:
    -- grr - References (we keep gr as well for backwards compatibility)
    -- gra - Code Action
    -- grn - Rename
    -- gri - Implementation
    -- grt - Type Definition
    -- gO - Document Symbols
    -- K - Hover
    -- <C-S> (insert mode) - Signature Help

    -- Add backwards-compatible mappings
    map("n", "gr", vim.lsp.buf.references, "References")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    map("n", "gI", vim.lsp.buf.implementation, "Goto Implementation")
    map("n", "gy", vim.lsp.buf.type_definition, "Goto Type Definition")

    -- Codelens support
    if client and client.supports_method("textDocument/codeLens") then
      map({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
      map("n", "<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens")

      -- Auto refresh codelens
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        buffer = bufnr,
        callback = vim.lsp.codelens.refresh,
      })
    end

    -- Clangd-specific keymaps
    if client and client.name == "clangd" then
      map("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", "Switch Source/Header (C/C++)")

      -- Setup clangd_extensions if available
      local ok, clangd_ext = pcall(require, "clangd_extensions")
      if ok then
        -- clangd_extensions is already set up in plugins/clang.lua
        -- Just enable inlay hints if supported
        if client.supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end
    end

    -- Enable inlay hints for supported servers
    if client and client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    -- Document highlight on hover
    if client and client.supports_method("textDocument/documentHighlight") then
      local highlight_group = augroup("document_highlight")
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = bufnr,
        group = highlight_group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = bufnr,
        group = highlight_group,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

-- ============================================================================
-- Custom LspInfo Command
-- ============================================================================

-- Create a custom LspInfo command to show LSP status
vim.api.nvim_create_user_command("LspInfo", function()
  local buf = vim.api.nvim_create_buf(false, true)
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local all_clients = vim.lsp.get_clients()

  local lines = {
    "LSP Client Information",
    "======================",
    "",
  }

  -- Show clients attached to current buffer
  if #clients > 0 then
    table.insert(lines, "Clients attached to current buffer:")
    for _, client in ipairs(clients) do
      table.insert(lines, "")
      table.insert(lines, string.format("  Client: %s (id: %d)", client.name, client.id))
      table.insert(lines, string.format("  Root dir: %s", client.root_dir or "N/A"))
      table.insert(lines, string.format("  Filetypes: %s", table.concat(client.config.filetypes or {}, ", ")))
      table.insert(lines, string.format("  Autostart: %s", client.config.autostart and "true" or "false"))

      -- Show capabilities
      if client.server_capabilities then
        local caps = {}
        if client.server_capabilities.completionProvider then table.insert(caps, "completion") end
        if client.server_capabilities.hoverProvider then table.insert(caps, "hover") end
        if client.server_capabilities.definitionProvider then table.insert(caps, "definition") end
        if client.server_capabilities.referencesProvider then table.insert(caps, "references") end
        if client.server_capabilities.documentFormattingProvider then table.insert(caps, "formatting") end
        if client.server_capabilities.renameProvider then table.insert(caps, "rename") end
        if client.server_capabilities.codeActionProvider then table.insert(caps, "code_action") end
        table.insert(lines, string.format("  Capabilities: %s", table.concat(caps, ", ")))
      end
    end
  else
    table.insert(lines, "No clients attached to current buffer")
  end

  -- Show all active clients
  table.insert(lines, "")
  table.insert(lines, "")
  table.insert(lines, "All active LSP clients:")
  if #all_clients > 0 then
    for _, client in ipairs(all_clients) do
      table.insert(lines, string.format("  - %s (id: %d)", client.name, client.id))
    end
  else
    table.insert(lines, "  No active LSP clients")
  end

  -- Show configured servers
  table.insert(lines, "")
  table.insert(lines, "")
  table.insert(lines, "Configured LSP servers:")
  table.insert(lines, "  - clangd")
  table.insert(lines, "  - gopls")
  table.insert(lines, "  - lua_ls")
  table.insert(lines, "  - pyright")
  table.insert(lines, "  - elixirls")
  table.insert(lines, "  - rust_analyzer (via rustaceanvim)")

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "lspinfo"

  -- Open in a floating window
  local width = 80
  local height = math.min(#lines + 2, vim.o.lines - 4)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " LSP Info ",
    title_pos = "center",
  })

  -- Set keymaps for the window
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, nowait = true })
end, {})

-- ============================================================================
-- Enable LSP servers
-- ============================================================================

function M.setup()
  -- Enable all configured servers
  vim.lsp.enable('clangd')
  vim.lsp.enable('gopls')
  vim.lsp.enable('lua_ls')
  vim.lsp.enable('pyright')
  vim.lsp.enable('elixirls')
  -- Note: rust_analyzer is handled by rustaceanvim plugin
end

return M
