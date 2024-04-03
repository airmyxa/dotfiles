return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      folder_closed = "",
      icon = {
        folder_open = "",
        folder_empty = "󰜌",
        -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
        -- then these will never be used.
        default = "*",
        highlight = "NeoTreeFileIcon",
      },
    },
  },
}
