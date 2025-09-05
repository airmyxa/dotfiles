return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "c",
        "cpp",
        "lua",
        "go",
        "rust",
        "python",
        "markdown",
        "markdown_inline",
        "bash",
        "vim",
        "query",
        "json",
        "yaml",
        "toml",
        "sql",
      },
      highlight = { enable = true },
      indent = { enable = true },
      auto_install = true,
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
