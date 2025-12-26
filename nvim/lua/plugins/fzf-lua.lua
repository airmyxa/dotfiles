return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			-- Buffer switching
			{
				"<leader>,",
				function()
					require("fzf-lua").buffers()
				end,
				desc = "Switch Buffer",
			},
			-- Grep
			{
				"<leader>/",
				function()
					require("fzf-lua").live_grep()
				end,
				desc = "Grep (Root Dir)",
			},
			{
				"<leader>sg",
				function()
					require("fzf-lua").live_grep()
				end,
				desc = "Grep (Root Dir)",
			},
			{
				"<leader>sw",
				function()
					require("fzf-lua").grep_cword()
				end,
				desc = "Word (Root Dir)",
			},
			{
				"<leader>sw",
				function()
					require("fzf-lua").grep_visual()
				end,
				mode = "v",
				desc = "Selection (Root Dir)",
			},
			-- Git
			{
				"<leader>gc",
				function()
					require("fzf-lua").git_commits()
				end,
				desc = "Commits",
			},
			{
				"<leader>gs",
				function()
					require("fzf-lua").git_status()
				end,
				desc = "Status",
			},
			-- Search
			{
				'<leader>s"',
				function()
					require("fzf-lua").registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>sa",
				function()
					require("fzf-lua").autocmds()
				end,
				desc = "Auto Commands",
			},
			{
				"<leader>sb",
				function()
					require("fzf-lua").lgrep_curbuf()
				end,
				desc = "Buffer",
			},
			{
				"<leader>sC",
				function()
					require("fzf-lua").commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>sd",
				function()
					require("fzf-lua").diagnostics_document()
				end,
				desc = "Document Diagnostics",
			},
			{
				"<leader>sD",
				function()
					require("fzf-lua").diagnostics_workspace()
				end,
				desc = "Workspace Diagnostics",
			},
			{
				"<leader>sh",
				function()
					require("fzf-lua").help_tags()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>sH",
				function()
					require("fzf-lua").highlights()
				end,
				desc = "Search Highlight Groups",
			},
			{
				"<leader>sk",
				function()
					require("fzf-lua").keymaps()
				end,
				desc = "Key Maps",
			},
			{
				"<leader>sq",
				function()
					require("fzf-lua").quickfix()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>ss",
				function()
					require("fzf-lua").lsp_document_symbols()
				end,
				desc = "Goto Symbol",
			},
			{
				"<leader>sS",
				function()
					require("fzf-lua").lsp_workspace_symbols()
				end,
				desc = "Goto Symbol (Workspace)",
			}
		},
		opts = {
			winopts = {
				height = 0.85,
				width = 0.80,
				row = 0.35,
				col = 0.50,
				border = "rounded",
				preview = {
					layout = "vertical",
					vertical = "down:45%",
				},
			},
		},
	},
}
