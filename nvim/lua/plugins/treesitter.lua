-- Neovim 0.12 ships built-in parsers for c, lua, markdown, markdown_inline,
-- query, vim, vimdoc — no install needed for those. Highlighting/folding/
-- indents are exposed via vim.treesitter.* directly.
--
-- nvim-treesitter was archived 2026-04-03; tree-sitter-manager.nvim replaces
-- :TSInstall and registers FileType autocmds for installed parsers.
-- Requires `tree-sitter` CLI on PATH (brew install tree-sitter).
return {
  {
    "romus204/tree-sitter-manager.nvim",
    lazy = false,
    cmd = "TSManager",
    config = function()
      require("tree-sitter-manager").setup({
        ensure_installed = {
          "bash",
          "cpp",
          "elixir",
          "go",
          "gomod",
          "gosum",
          "gowork",
          "heex",
          "hurl",
          "json",
          "python",
          "regex",
          "rust",
          "tsx",
          "typescript",
          "yaml",
        },
        auto_install = true,
        highlight = true,
      })
    end,
  },
}
