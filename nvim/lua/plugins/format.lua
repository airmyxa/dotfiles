return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        rust = { "rustfmt", lsp_format = "fallback" },
        javascript = { "prettier", "prettier", stop_after_first = true },
        json = { "prettier" },
        go = { "gofmt", "goimports", "golines" },
        cpp = { "ya_format" },
      },
      formatters = {
        ya_format = {
          command = "ya",
          args = { "tool", "tt", "format", "$FILENAME" },
          stdin = false,
        },
        -- Add 'condition' that file is in arcadia
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
    },
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        -- Customize or remove this keymap to your liking
        "<leader>cf",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
  },
}
