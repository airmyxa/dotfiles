-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("my_lazyvim_" .. name, { clear = true })
end

local is_stable_version = true

if is_stable_version then
  -- Set filetype for .hurl files
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup("env_filetype"),
    pattern = { "*.hurl" },
    callback = function()
      vim.opt_local.filetype = "sh"
    end,
  })
end
