return {
  "mikavilpas/yazi.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = "VeryLazy",
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      "<leader>yy",
      function()
        require("yazi").yazi()
      end,
      desc = "Open the file manager",
    },
    {
      -- Open in the current working directory
      "<leader>yw",
      function()
        require("yazi").yazi(nil, vim.uv.cwd())
      end,
      desc = "Open the file manager in nvim's working directory",
    },
  },
  opts = {
    open_for_directories = false,
  },
}
