-- LSP-related plugins
-- Note: LSP server configuration is now in lua/config/lsp.lua using modern vim.lsp.config

return {
  -- Completion plugin
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
    },
    opts = function()
      local cmp = require("cmp")
      return {
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          -- Tab support
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          -- Scrolling
          ["<C-S-f>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          -- Trigger completion
          ["<A-Space>"] = cmp.mapping.complete(),
          -- Close completion menu
          ["<C-e>"] = cmp.mapping.close(),
          -- Confirm selection
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
        }),
        -- Completion sources
        sources = cmp.config.sources({
          { name = "nvim_lsp", keyword_length = 3 }, -- LSP completion
          { name = "nvim_lsp_signature_help" }, -- Function signatures
          { name = "nvim_lua", keyword_length = 2 }, -- Neovim Lua API
          { name = "vsnip", keyword_length = 2 }, -- Snippets
          { name = "path" }, -- File paths
        }, {
          { name = "buffer", keyword_length = 2 }, -- Buffer words
          { name = "calc" }, -- Math calculations
        }),
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
              nvim_lua = "🌙",
            }
            item.menu = menu_icon[entry.source.name]
            return item
          end,
        },
        experimental = {
          ghost_text = true,
        },
      }
    end,
  },
}
