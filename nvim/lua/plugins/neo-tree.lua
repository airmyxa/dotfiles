return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle" },
    init = function()
      -- Чтобы не конфликтовать с встроенным netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      view = { width = 34 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
      actions = { open_file = { quit_on_open = false } },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Explorer" })
      vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeFindFileToggle<cr>", { desc = "Find current in Explorer" })
    end,
  },
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   opts = {
  --     folder_closed = "",
  --     icon = {
  --       folder_open = "",
  --       folder_empty = "󰜌",
  --       -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
  --       -- then these will never be used.
  --       default = "*",
  --       highlight = "NeoTreeFileIcon",
  --     },
  --   },
  --   keys = {
  --     {
  --       "<leader>e",
  --       function()
  --         require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
  --       end,
  --       desc = "Explorer NeoTree (cwd)",
  --       remap = true,
  --     },
  --     {
  --       "<leader>be",
  --       function()
  --         require("neo-tree.command").execute({ source = "buffers", toggle = true })
  --       end,
  --       desc = "Buffer Explorer",
  --     },
  --   },
  -- },
}
