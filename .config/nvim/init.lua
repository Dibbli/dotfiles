-- init.lua

-- Install lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key
vim.g.mapleader = " "

-- Vim options
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.scrolloff = 8
vim.opt.background = "dark"
vim.opt.listchars = { tab = "▏ " }
vim.opt.showtabline = 2
vim.opt.laststatus = 2
vim.opt.wildmenu = true
vim.opt.wrap = false
vim.opt.timeoutlen = 200
vim.opt.syntax = "on"
vim.opt.foldenable = false
vim.opt.foldmethod = "syntax"
vim.opt.autoread = true
vim.opt.termguicolors = true
vim.opt.autoread = true
vim.g.vsnip_snippet_dir = "~/.config/nvim/snippets"
vim.cmd("filetype plugin indent on")

-- Terminal compatibility
if vim.fn.empty(vim.env.TMUX) == 1 and vim.env.TERM_PROGRAM ~= "Apple_Terminal" then
	if vim.fn.has("nvim") == 1 then
		vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
	end
	if vim.fn.has("termguicolors") == 1 then
		vim.opt.termguicolors = true
	end
end

-- Plugin setup
require("lazy").setup({

	-- Sensible Defaults
	{ "tpope/vim-sensible" },

	-- TypeScript and JavaScript Support
	{ "leafgarland/typescript-vim" },
	{ "Quramy/vim-js-pretty-template" },
	{ "pangloss/vim-javascript" },

	-- LSP Configurations
	{ "neovim/nvim-lspconfig" },
	{
		"pmizio/typescript-tools.nvim",
		config = function()
			require("typescript-tools").setup({})
		end,
	},

	-- LSP Installer
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup()
		end,
	},

	-- UI Components
	{ "MunifTanjim/nui.nvim" },

	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({})
		end,
	},
	--Substitute
	{
		"gbprod/substitute.nvim",
		config = function()
			require("substitute").setup({})
		end,
	},

	-- File Explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				popup_border_style = "rounded",
				enable_git_status = true,
				enable_diagnostics = true,
				use_libuv_file_watcher = true,
				follow_current_file = {
					enable = false,
					leave_dirs_open = false,
				},
			})
		end,
	},

	-- Telescope Fuzzy Finder
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup()
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").load_extension("ui-select")
		end,
	},

	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},

	-- Treesitter for Syntax Highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "lua", "javascript", "typescript", "css", "html", "kotlin", "json", "jsonc", "angular", "dockerfile", "scss" },
				highlight = {
					enable = true,
				},
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	-- Icons
	{ "nvim-tree/nvim-web-devicons" },

	-- Git Integration
	{ "tpope/vim-fugitive" },
	{ "tpope/vim-rhubarb" },
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
    "f-person/git-blame.nvim",
    event = "VeryLazy",
	},
	{
		"kdheepak/lazygit.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Minimap and Scrollbar
	{
		"Isrothy/neominimap.nvim",
		config = function()
			require("neominimap").setup()
		end,
	},
	{
		"lewis6991/satellite.nvim",
		config = function()
			require("satellite").setup()
		end,
	},

	-- Otter for R and Quarto files
	{
		"jmbuhr/otter.nvim",
		config = function()
			require("otter").setup()
		end,
	},

	-- AI Code Completion
	{
		"monkoose/neocodeium",
		config = function()
			require("neocodeium").setup()
		end,
	},

	-- Image Support
	{
		"3rd/image.nvim",
		config = function()
			require("image").setup()
		end,
	},

	-- Sniprun
	{
		"michaelb/sniprun",
		build = "bash ./install.sh",
		config = function()
			require("sniprun").setup()
		end,
	},

	-- Commenting
	{ "tpope/vim-commentary" },

	-- Hover
	{
		"lewis6991/hover.nvim",
		config = function()
			require("hover").setup({
				init = function()
					require("hover.providers.lsp")
				end,
				preview_opts = {
					border = nil,
				},
				preview_window = false,
				title = true,
			})
		end,
	},

	-- Completion Plugins
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-vsnip",
			"hrsh7th/vim-vsnip",
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				formatting = {
					format = require("tailwindcss-colorizer-cmp").formatter,
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "vsnip" },
					{ name = "tailwind_tools" },
				}, {
					{ name = "path" },
				}),
			})

			-- Set configuration for specific filetype
			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources({
					{ name = "cmp_git" },
				}, {
					{ name = "buffer" },
				}),
			})

			-- Use buffer source for `/` and `?`
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':'
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
				matching = { disallow_symbol_nonprefix_matching = false },
			})
		end,
	},

	-- Colorschemes
	{
		"morhetz/gruvbox",
		config = function()
			vim.cmd("colorscheme gruvbox")
		end,
	},

	{
		"maxmx03/solarized.nvim",
		config = function()
			require("solarized").setup({
				theme = "neovim",
				config = {
					theme = "dark",
					italics = true,
				},
			})
		end,
	},

	-- Lush
	{ "rktjmp/lush.nvim" },

	-- Indentation Detection
	{
		"nmac427/guess-indent.nvim",
		config = function()
			require("guess-indent").setup({})
		end,
	},

	-- Highlight Code Chunks
	{
		"shellRaining/hlchunk.nvim",
		config = function()
			require("hlchunk").setup({
				chunk = {
					enable = true,
					use_treesitter = true,
					chars = {
						horizontal_line = "─",
						vertical_line = "│",
						left_top = "┌",
						left_bottom = "└",
						right_arrow = "─",
					},
				},
				indent = {
					enable = true,
				},
				blank = {
					enable = true,
				},
			})
		end,
	},

	-- Debugging
	{
		"mfussenegger/nvim-dap",
		config = function()
			-- nvim-dap configurations
		end,
	},

	-- Terminal Management
	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup()
		end,
	},

	-- Surround
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup()
		end,
	},

	-- Colorizer
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},

	-- Auto-tagging
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	-- Tailwind Tools
	{
		"luckasRanarison/tailwind-tools.nvim",
		config = function()
			require("tailwind-tools").setup({})
		end,
	},

	-- CSS Syntax
	{ "hail2u/vim-css3-syntax" },

	-- Tailwind CSS Colorizer for Completion Menu
	{
		"roobert/tailwindcss-colorizer-cmp.nvim",
		config = function()
			require("tailwindcss-colorizer-cmp").setup({
				color_square_width = 2,
			})
		end,
	},

	-- Kotlin Support
	{ "udalov/kotlin-vim" },

	-- Guard.nvim for Formatting and Linting
	{
		"nvimdev/guard.nvim",
		dependencies = {
			"nvimdev/guard-collection",
		},
		config = function()
			local ft = require("guard.filetype")

			ft("javascript,typescript"):fmt("prettier")
			ft("lua"):fmt("stylua")
			ft("kotlin"):fmt("ktlint")
			ft("html"):lint({
				cmd = "eslint",
				args = { "--stdin", "--stdin-filename", "%filepath", "--format", "json" },
				stdin = true,
				ignore_exitcode = true,
			})
			ft("htmlangular"):lint({
				cmd = "eslint",
				args = { "--stdin", "--stdin-filename", "%filepath", "--format", "json" },
				stdin = true,
				ignore_exitcode = true,
			})
			ft("htmlangular"):fmt("prettier")
			require("guard").setup({
				fmt_on_save = true,
				lsp_as_default_formatter = false,
			})
		end,
	},

	-- Noice.nvim for Enhanced UI
	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				presets = {
					bottom_search = true,
					command_palette = true,
					long_message_to_split = true,
				},
			})
		end,
	},

	-- Trouble.nvim for Diagnostics List
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup()
		end,
	},

	-- Harpoon for Quick File Navigation
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon").setup()
		end,
	},

	-- Grapple for File Tagging
	{
		"cbochs/grapple.nvim",
		config = function()
			require("grapple").setup()
		end,
	},
})
vim.cmd("colorscheme gruvbox")
-- nvim-web-devicons setup
require("nvim-web-devicons").setup()

-- Mason and LSP configurations
require("mason").setup()

require("mason-lspconfig").setup({
	ensure_installed = {
		"angularls",
		"cssls",
		"tailwindcss",
		"jsonls",
		"eslint",
		"lua_ls",
		"kotlin_language_server",
		"pyright",
	},
	automatic_installation = true,
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- LSP servers setup
local servers = { "kotlin_language_server", "jsonls", "cssls", "angularls", "pyright" }

for _, server in ipairs(servers) do
	lspconfig[server].setup({
		capabilities = capabilities,
	})
end
lspconfig.eslint.setup({
	capabilities = capabilities,
	filetypes = { "typescript", "typescriptreact", "html", "htmlangular", "scss" },
	on_attach = function(client, bufnr)
		-- Auto-fix ESLint issues on save
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
	handlers = {
    ["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics,
        { virtual_text = false, signs = true, update_in_insert = false, underline = true}
    ),
  }
})

lspconfig.tailwindcss.setup({
	capabilities = capabilities,
	filetypes = { "html", "htmlangular", "scss" },
})
lspconfig.lua_ls.setup({
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

-- Function to get the node_modules path
local function get_node_modules(root_dir)
	local root_node = lspconfig.util.find_node_modules_ancestor(root_dir)
	return root_node and lspconfig.util.path.join(root_node, "node_modules") or ""
end

-- Angularls setup
lspconfig.angularls.setup({
	on_attach = function(client, bufnr)
		local buf_set_keymap = function(...)
			vim.api.nvim_buf_set_keymap(bufnr, ...)
		end
		buf_set_keymap("n", "<leader>l", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
	end,
	on_new_config = function(new_config, new_root_dir)
		local node_modules = get_node_modules(new_root_dir)
		if node_modules ~= "" then
			new_config.cmd = {
				"ngserver",
				"--stdio",
				"--tsProbeLocations",
				node_modules,
				"--ngProbeLocations",
				node_modules,
			}
		end
	end,
	root_dir = function(fname)
		local util = lspconfig.util
		return util.root_pattern("angular.json", "project.json")(fname) or util.root_pattern("nx.json", ".git")(fname)
	end,

	filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
	capabilities = capabilities,
})

-- Tailwind Tools
require("tailwind-tools").setup({})

-- Colorizer
require("colorizer").setup()

-- nvim-surround
require("nvim-surround").setup()

-- Telescope extensions
require("telescope").load_extension("fzf")

-- neocodeium
require("neocodeium").setup()

-- nvim-ts-autotag
require("nvim-ts-autotag").setup()

-- guess-indent
require("guess-indent").setup({})

-- Keymaps
local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

-- Keymaps to switch themes
map("n", "<leader>gt", ":lua vim.cmd('colorscheme gruvbox')<CR>", opts)
map("n", "<leader>st", ":lua require('solarized').load('dark')<CR>", opts)

-- LSP keymaps
vim.api.nvim_set_keymap("n", "<leader>i", ":lua vim.lsp.buf.code_action()<CR>", opts)
vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
vim.keymap.set("i", "<leader>a", require("neocodeium").accept)
vim.keymap.set("n", "s", require("substitute").operator, { noremap = true })
vim.keymap.set("n", "ss", require("substitute").line, { noremap = true })
vim.keymap.set("n", "S", require("substitute").eol, { noremap = true })
vim.keymap.set("x", "s", require("substitute").visual, { noremap = true })

-- Neo-tree
vim.keymap.set({ "n" }, "-", ":Neotree reveal position=left toggle<cr>", { desc = "Toggle neotree" })

-- Additional keymaps
map("n", "<leader>c", ":Commentary<CR>", opts)
map("v", "<leader>c", ":Commentary<CR>", opts)
map("n", "<leader>gg", ":LazyGit<CR>", opts)
map("n", "<leader>z", ":u<CR>", opts)
map("n", "<leader>g", ":Telescope find_files<CR>", opts)
map("n", "<leader>f", ":Telescope live_grep<CR>", opts)
map("n", "<leader>y", ":red<CR>", opts)
map("n", "=", ":ToggleTerm size=10 direction=horizontal <CR>", opts)
map("t", "<leader><Esc>", [[<C-\><C-n><C-w>k]], opts)
map("n", "<leader>w", ":w<CR>", opts)
map("n", "<leader>ww", ":wall<CR>", opts)
map("n", "<Tab>", ":BufferLineCycleNext<CR>", opts)
map("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", opts)

-- Bound higher up
-- <leader>l = Go to Definition (LSP)
