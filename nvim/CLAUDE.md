# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration built on **lazy.nvim** as the plugin manager. It uses the **modern vim.lsp.config API** (Neovim 0.10+) rather than nvim-lspconfig.

## Key Architecture

**Initialization flow:**
1. `init.lua` → bootstraps lazy.nvim via `lua/config/lazy.lua`, then loads `config.keymaps`, `config.options`
2. On `VeryLazy` event → `config.lsp.setup()` initializes language servers
3. All plugin specs live in `lua/plugins/` (one file per plugin/group)

**LSP setup** (`lua/config/lsp.lua`): Uses `vim.lsp.config` and `vim.lsp.enable` directly — not nvim-lspconfig. Servers: clangd, gopls, lua_ls, pyright, elixirls. Rust is handled by rustaceanvim (in `lua/plugins/rust.lua`).

**Plugin management**: lazy.nvim auto-discovers all files under `lua/plugins/`. To disable a plugin, set `enabled = false` in its spec (see telescope.lua and neo-tree.lua as examples of disabled alternatives).

**Primary fuzzy finder**: fzf-lua (telescope is disabled). Keybindings follow `<leader>s*` for search, `<leader>f*` for files.

## Adding/Modifying Language Servers

- LSP server configs go in `lua/config/lsp.lua` using `vim.lsp.config('name', {...})` + `vim.lsp.enable('name')`
- Mason tool installation list is in `lua/plugins/mason.lua`
- Formatters are configured in `lua/plugins/format.lua` (conform.nvim)
- Treesitter parsers are listed in `lua/plugins/treesitter.lua` (managed by tree-sitter-manager.nvim since nvim-treesitter was archived 2026-04-03; Neovim 0.12 bundles c/lua/markdown/markdown_inline/query/vim/vimdoc — do not list them in `ensure_installed`)

## Key Keybindings

- `<leader>` = Space, local leader = `\`
- `<leader>e` / `-` — oil.nvim file explorer (floating)
- `<leader>gg` — gitui in floating terminal
- `<leader>sr` — grug-far search & replace
- `<leader>ca` — code action, `K` — hover, `gd` — definition
- `<leader>d*` — DAP debug commands
- `<C-s>` — save file

## Plugin Version Lock

`lazy-lock.json` pins all plugin versions. After changing plugin specs, run `:Lazy sync` inside Neovim to update and regenerate the lock file.
