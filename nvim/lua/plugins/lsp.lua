return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "mason.nvim",
      { "williamboman/mason-lspconfig.nvim" },
    },
    keys = {
      { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
      { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
      { "gr", vim.lsp.buf.references, desc = "References", nowait = true },
      { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
      { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
      { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
      { "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },
      { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
      { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" } },
      { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" } },
      { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
    },
    opts = {
      servers = {
        clangd = {
          cmd = (function()
            -- allow both AppleClang and Homebrew clang drivers
            local drivers = table.concat({
              "/usr/bin/clang",
              "/usr/bin/clang++",
              "/opt/homebrew/opt/llvm/bin/clang",
              "/opt/homebrew/opt/llvm/bin/clang++",
            }, ",")
            return {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--fallback-style=llvm",
              "--query-driver=" .. drivers,
            }
          end)(),
          keys = {
            { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "Makefile",
              "configure.ac",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja"
            )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
              fname
            ) or require("lspconfig.util").find_git_ancestor(fname)
          end,
          init_options = (function()
            local sdk = vim.fn.trim(vim.fn.system("xcrun --show-sdk-path"))
            local flags = { "-std=c++20" }
            if sdk ~= "" then
              table.insert(flags, "-isysroot")
              table.insert(flags, sdk)
              table.insert(flags, "-I" .. sdk .. "/usr/include/c++/v1")
            end
            return {
              usePlaceholders = true,
              completeUnimported = true,
              clangdFileStatus = true,
              fallbackFlags = flags,
            }
          end)(),
          autostart = true,
          setup = {
            clangd = function(_, opts)
              local clangd_ext_opts = require("clangd_extensions").opts
              require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
              return false
            end,
          },
        },
        gopls = {
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
          cmd = { "/Users/airmyxa/.ya/tools/v4/gopls-darwin-arm64/gopls" },
        },
        jedi_language_server = {
          cmd = { "jedi-language-server" }, -- ensure it's on PATH (pipx/pip/Mason)
          filetypes = { "python" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("pyproject.toml", "setup.cfg", "setup.py", "Pipfile", "requirements.txt", ".git")(
              fname
            )
          end,
          -- Jedi expects initializationOptions -> use init_options in lspconfig
          init_options = {
            markupKindPreferred = "markdown",
            completion = { disableSnippets = false, resolveEagerly = false, ignorePatterns = {} },
            diagnostics = { enable = true, didOpen = true, didChange = true, didSave = true },
            jediSettings = { caseInsensitiveCompletion = true, autoImportModules = {} },
            workspace = {
              environmentPath = nil, -- filled dynamically in before_init
              extraPaths = {},
              symbols = { ignoreFolders = { ".nox", ".tox", ".venv", "__pycache__", "venv" }, maxSymbols = 20 },
            },
            semanticTokens = { enable = false },
            hover = { enable = true },
            codeAction = { nameExtractVariable = "jls_extract_var", nameExtractFunction = "jls_extract_def" },
          },
          -- pick the right interpreter (venv > python3 > python)
          before_init = function(_, config)
            local function detect_python()
              local sep = package.config:sub(1, 1)
              local venv = vim.env.VIRTUAL_ENV
              if venv and venv ~= "" then
                local candidate = venv .. (sep == "\\" and "\\Scripts\\python.exe" or "/bin/python")
                if vim.fn.executable(candidate) == 1 or vim.fn.filereadable(candidate) == 1 then
                  return candidate
                end
              end
              local py3 = vim.fn.exepath("python3")
              if py3 ~= "" then
                return py3
              end
              local py = vim.fn.exepath("python")
              if py ~= "" then
                return py
              end
              return "python3"
            end
            config.init_options = config.init_options or {}
            config.init_options.workspace = config.init_options.workspace or {}
            config.init_options.workspace.environmentPath = detect_python()
          end,
        },
      },
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      for server, server_opts in pairs(opts.servers) do
        lspconfig[server].setup(server_opts)
      end
    end,
  },
  {
    "segoon/yamake-python-lspconfig.nvim",
    config = function(_, opts)
      require("yamake-python-lspconfig").setup({
        -- autorestart LSP after pyrightconfig.json (re)generation
        autorestart_lsp = true,
        -- do not ask for "generate config?" if it is missing
        autogenerate_config = false,
        -- root directory for dummy vscode ide project
        ide_rootdir = os.getenv("HOME") .. "/.local/share/nvim/yamake-python-lspconfig",
        -- if true, generate pyrightconfig.json file near ya.make
        -- if false, generate it in `ide_rootdir` subdirectory
        is_config_in_arcadia = false,
      })
    end,
  },
  { "j-hui/fidget.nvim", opts = {} },
  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/nvim-cmp",
      "hrsh7th/vim-vsnip",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      return {
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = {
          -- Add tab support
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<C-S-f>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<A-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
        },
        -- Installed sources:
        sources = {
          { name = "path" }, -- file paths
          { name = "nvim_lsp", keyword_length = 3 }, -- from language server
          { name = "nvim_lsp_signature_help" }, -- display function signatures with current parameter emphasized
          { name = "nvim_lua", keyword_length = 2 }, -- complete neovim's Lua runtime API such vim.lsp.*
          { name = "buffer", keyword_length = 2 }, -- source current buffer
          { name = "vsnip", keyword_length = 2 }, -- nvim-cmp source for vim-vsnip
          { name = "calc" }, -- source for math calculation
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          fields = { "menu", "abbr", "kind" },
          format = function(entry, item)
            local menu_icon = {
              nvim_lsp = "λ",
              vsnip = "⋗",
              buffer = "Ω",
              path = "🖫",
            }
            item.menu = menu_icon[entry.source.name]
            return item
          end,
        },
      }
    end,
  },
}
