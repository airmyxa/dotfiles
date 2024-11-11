return {
  {
    "williamboman/mason.nvim",
    dependencies = { { "williamboman/mason-lspconfig.nvim" } },
    cmd = "Mason",
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "shellcheck",
        "shfmt",
        "autoflake",
        "autopep8",
        "black",
        "clang-format",
        "clangd",
        "codelldb",
        "cpplint",
        "cpptools",
        "flake8",
        "go-debug-adapter",
        "delve",
        "gofumpt",
        "goimports",
        "goimports-reviser",
        "golangci-lint",
        "golangci-lint-langserver",
        "golines",
        "gomodifytags",
        "gopls",
        "gotests",
        "gotestsum",
        "isort",
        "lua-language-server",
        "mypy",
        "prettier",
        "pydocstyle",
        "pylint",
        "pyright",
        "ruff",
        "ruff-lsp",
        "rust-analyzer",
        "shellcheck",
        "shfmt",
        "stylua",
        "gitui",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
    end,
    keys = {
      {
        "<leader>gg",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          local gitui = Terminal:new({
            cmd = "gitui",
            hidden = true,
            direction = "float",
          })
          gitui:toggle()
        end,
        desc = "GitUi (Root Dir)",
      },
    },
  },
  { "williamboman/mason-lspconfig.nvim" },
}
