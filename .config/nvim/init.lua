-- Install lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- lua_ls is lying, this is defined
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.env.PATH = vim.env.PATH .. ":/home/dibbli/.volta/bin"
vim.opt.rtp:prepend(lazypath)
vim.opt.clipboard = { "unnamed", "unnamedplus" }
-- Set leader key
vim.g.mapleader = " "
-- Vim options
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.scrolloff = 8
vim.opt.background = "dark"
vim.opt.listchars = { tab = "▏ " }
vim.opt.showtabline = 0
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
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.laststatus = 3
vim.g.vsnip_snippet_dir = "~/.config/nvim/snippets"
vim.cmd("filetype plugin indent on")

-- Plugin setup
require("lazy").setup({

	-- Sensible Defaults
	{ "tpope/vim-sensible" },

	-- TypeScript and JavaScript Support
	{ "leafgarland/typescript-vim" },
	{ "Quramy/vim-js-pretty-template" },
	{ "pangloss/vim-javascript" },

	-- LSP Configurations
	{
		"neovim/nvim-lspconfig",
		keys = {
			{
				"<leader>i",
				":lua vim.lsp.buf.code_action()<CR>",
				mode = "n",
				noremap = true,
				silent = true,
				desc = "Code Action",
			},
			{
				"<leader>l",
				":lua vim.lsp.buf.definition()<CR>",
				mode = "n",
				noremap = true,
				silent = true,
				desc = "Go to Definition",
			},
		},
	},

	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {},
		config = function()
			require("typescript-tools").setup({
				root_dir = require("lspconfig").util.root_pattern("tsconfig.base.json"),
			})
		end,
	},

	-- LSP Installer
	{
		"williamboman/mason.nvim",
	},
	{
		"williamboman/mason-lspconfig.nvim",
	},

	-- UI Components
	{ "MunifTanjim/nui.nvim" },

	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		config = function()
			require("dashboard").setup({
				theme = "hyper",
				config = {
					header = {
						"███╗   ██╗██╗   ██╗██╗███╗   ███╗",
						"████╗  ██║██║   ██║██║████╗ ████║",
						"██╔██╗ ██║██║   ██║██║██╔████╔██║",
						"██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
						"██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
						"╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
						"",
						"",
					},
					footer = {
						"v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
					},
				},
			})
		end,
		dependencies = { { "nvim-tree/nvim-web-devicons" } },
	},
	{
		"oncomouse/lushwal.nvim",
		cmd = { "LushwalCompile" },
		dependencies = {
			{ "rktjmp/lush.nvim" },
			{ "rktjmp/shipwright.nvim" },
		},
	},

	--Color picker
	{
		"nvzone/minty",
		cmd = { "Shades", "Huefy" },
		keys = {
			{
				"<leader>o",
				":Huefy<CR>",
				mode = "n",
				noremap = true,
				silent = true,
				desc = "Huefy",
			},
			{
				"<leader>oo",
				":Shades<CR>",
				mode = "n",
				noremap = true,
				silent = true,
				desc = "Shades",
			},
		},
		dependencies = { "nvzone/volt" },
	},
	{
		"nvzone/timerly",
		dependencies = {
			"nvzone/volt",
			keys = {
				{
					"<leader>p",
					":TimerlyToggle<CR>",
					mode = "n",
					noremap = true,
					desc = "Substitute Operator",
				},
			},
		},
	},
	-- Substitute
	{
		"gbprod/substitute.nvim",
		keys = {
			{
				"s",
				function()
					require("substitute").operator()
				end,
				mode = "n",
				noremap = true,
				desc = "Substitute Operator",
			},
			{
				"ss",
				function()
					require("substitute").line()
				end,
				mode = "n",
				noremap = true,
				desc = "Substitute Line",
			},
			{
				"S",
				function()
					require("substitute").eol()
				end,
				mode = "n",
				noremap = true,
				desc = "Substitute to End of Line",
			},
			{
				"s",
				function()
					require("substitute").visual()
				end,
				mode = "x",
				noremap = true,
				desc = "Substitute Visual",
			},
		},
	},
	-- Find and Replace
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>s",
				function()
					require("spectre").toggle()
				end,
				mode = "n",
				desc = "Toggle Spectre",
			},
			{
				"<leader>s",
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				mode = "v",
				desc = "Search Current Word",
			},
			{
				"<leader>sc",
				function()
					require("spectre").open_file_search({ select_word = true })
				end,
				mode = "n",
				desc = "Search in Current File",
			},
			{
				"<leader>r",
				function()
					require("spectre.actions").run_replace()
				end,
				mode = "n",
				noremap = true,
				silent = true,
				desc = "Run Replace",
			},
		},
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
		keys = {
			{ "-", ":Neotree reveal position=left toggle<cr>", desc = "Toggle Neo-tree" },
		},
	},

	-- Telescope Fuzzy Finder
	{ "junegunn/fzf", build = "./install --bin" },
	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons", "junegunn/fzf" },
		keys = {
			{
				"<leader>f",
				function()
					require("fzf-lua").grep_visual()
				end,
				mode = "v",
				noremap = true,
				silent = true,
				desc = "Live Grep Selected Text",
			},
			{
				"<leader>g",
				function()
					require("fzf-lua").files()
				end,
				mode = "n",
				noremap = true,
				silent = true,
				desc = "Find Files",
			},
			{
				"<leader>f",
				function()
					require("fzf-lua").live_grep()
				end,
				mode = "n",
				noremap = true,
				silent = true,
				desc = "Live Grep",
			},
		},
		config = function()
			-- calling `setup` is optional for customization
			require("fzf-lua").setup({})
		end,
	},

	-- Treesitter for Syntax Highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"javascript",
					"typescript",
					"css",
					"html",
					"kotlin",
					"json",
					"jsonc",
					"angular",
					"dockerfile",
					"scss",
					"xml",
				},
				sync_install = false,
				ignore_install = {},
				auto_install = true,
				highlight = {
					enable = true,
				},
				modules = {},
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		config = true,
	},

	-- Icons
	{ "nvim-tree/nvim-web-devicons" },

	-- Git Integration
	{
		"lewis6991/gitsigns.nvim",
		config = true,
	},
	{
		"sindrets/diffview.nvim",
		config = true,
		keys = {
			{
				"<leader>dg",
				":DiffviewOpen<CR>",
				mode = "n",
				noremap = true,
				silent = true,
				desc = "Open diff view",
			},
			{
				"<leader>qg",
				":DiffviewClose<CR>",
				mode = "n",
				noremap = true,
				silent = true,
				desc = "Close diff view",
			},
		},
	},
	{
		"f-person/git-blame.nvim",
		event = "VeryLazy",
		opts = {
			date_format = "%r",
		},
	},
	{
		"kdheepak/lazygit.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>gg", ":LazyGit<CR>", mode = "n", noremap = true, silent = true, desc = "Open LazyGit" },
		},
	},

	{
		"lewis6991/satellite.nvim",
	},

	-- AI Code Completion
	{
		"monkoose/neocodeium",
		event = "VeryLazy",
		config = function()
			local neocodeium = require("neocodeium")
			neocodeium.setup()
			vim.keymap.set("i", "<leader>a", neocodeium.accept)
		end,
	},

	-- Commenting
	{
		"tpope/vim-commentary",
		keys = {
			{ "<leader>c", ":Commentary<CR>", mode = "n", noremap = true, silent = true, desc = "Toggle Comment" },
			{ "<leader>c", ":Commentary<CR>", mode = "v", noremap = true, silent = true, desc = "Toggle Comment" },
		},
	},

	-- Completion Plugins
	{
		"saghen/blink.cmp",
		version = "v0.*",
		lazy = false,
		dependencies = "rafamadriz/friendly-snippets",
		opts = {

			keymap = { preset = "super-tab" },

			appearance = {

				use_nvim_cmp_as_default = true,

				nerd_font_variant = "mono",
			},

			sources = {
				cmdline = function()
					local type = vim.fn.getcmdtype()
					if type == "/" or type == "?" then
						return { "buffer" }
					end
					-- Commands
					if type == ":" then
						return { "cmdline" }
					end
					return {}
				end,
				providers = {
					lsp = {
						score_offset = 2,
					},
					path = {
						score_offset = 1,
					},
					buffer = {
						score_offset = 0,
						max_items = 5,
					},
				},
			},
			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				menu = {
					draw = {
						treesitter = { "lsp" },
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
			},
		},
		signature = { enabled = true },
		opts_extend = { "sources.default" },
	},

	-- Colorschemes
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("gruvbox-material")
		end,
		keys = {
			{
				"<leader>gt",
				":lua vim.cmd('colorscheme gruvbox-material')<CR>",
				mode = "n",
				desc = "Switch to Gruvbox",
			},
		},
	},
	{
		"ficcdaf/ashen.nvim",
		lazy = false,
		priority = 1000,
		keys = {
			{
				"<leader>at",
				":lua vim.cmd('colorscheme ashen')<CR>",
				mode = "n",
				desc = "Switch to Ashen",
			},
		},
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
		keys = {
			{ "<leader>st", ":lua require('solarized').load('dark')<CR>", mode = "n", desc = "Switch to Solarized" },
		},
	},

	-- Lush
	{ "rktjmp/lush.nvim" },

	-- Indentation Detection
	{
		"nmac427/guess-indent.nvim",
		config = true,
	},

	{
		"rachartier/tiny-glimmer.nvim",
		event = "TextYankPost",
		opts = true,
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
	},

	-- Terminal Management
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = true,
		keys = {
			{
				"=",
				":ToggleTerm size=10 direction=horizontal <CR>",
				mode = "n",
				noremap = true,
				silent = true,
				desc = "Toggle Terminal",
			},
			{
				"<leader><Esc>",
				[[<C-\><C-n><C-w>k]],
				mode = "t",
				noremap = true,
				silent = true,
				desc = "Exit Terminal Mode",
			},
		},
	},

	-- Surround
	{
		"kylechui/nvim-surround",
		config = true,
	},

	-- Colorizer
	{
		"norcalli/nvim-colorizer.lua",
	},

	-- Auto-tagging
	{
		"windwp/nvim-ts-autotag",
		config = true,
	},

	-- CSS Syntax
	{ "hail2u/vim-css3-syntax" },

	-- Kotlin Support
	{ "udalov/kotlin-vim" },
	{
		"nvimdev/guard.nvim",
		dependencies = {
			"nvimdev/guard-collection",
		},
		config = function()
			local ft = require("guard.filetype")
			ft("json"):lint("eslint"):fmt("prettier")
			ft("jsonc"):lint("eslint"):fmt("prettier")
			ft("typescript"):lint("eslint"):fmt("prettier")
			ft("scss"):lint("eslint"):fmt("prettier")
			ft("css"):lint("eslint"):fmt("prettier")
			ft("lua"):fmt("stylua")
			ft("kotlin"):fmt("ktlint")
			ft("htmlangular"):lint("eslint"):fmt("prettier")
			ft("html"):lint("eslint"):fmt("prettier")
			ft("python"):lint("flake8"):fmt("black")
			vim.g.guard_config = {
				fmt_on_save = true,
				lsp_as_default_formatter = false,
				save_on_fmt = true,
			}
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
				messages = {
					view = "mini",
					opts = {
						position = {
							row = "100%",
							col = "100%",
						},
					},
				},
			})
		end,
	},
	-- Status line
	{
		"windwp/windline.nvim",
		config = function()
			-- Load the default configuration for windline
			require("wlsample.airline")
		end,
	},

	-- Trouble.nvim for Diagnostics List
	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
		},
	},

	-- Grapple for File Tagging
	{
		"cbochs/grapple.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			scope = "git_branch",
			icons = true,
			status = false,
		},
		keys = {
			{ "<leader>a", "<cmd>Grapple toggle<cr>", desc = "Tag a file" },
			{ "<leader>h", "<cmd>Grapple toggle_tags<cr>", desc = "Toggle tags menu" },
			{ "<leader><tab>", "<cmd>Grapple cycle_tags next<cr>", desc = "Go to next tag" },
		},
	},
})
vim.cmd("colorscheme ashen")
require("nvim-web-devicons").setup()

require("notify").setup({
	background_colour = "#000000",
})
require("colorizer").setup()
require("substitute").setup()

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

-- Function to get the node_modules path
local lspconfig_util = require("lspconfig.util")
local capabilities = require("blink.cmp").get_lsp_capabilities()
-- Setup handlers for Mason LSPconfig
require("mason-lspconfig").setup_handlers({
	-- Default handler for all servers
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = capabilities,
		})
	end,

	-- JSON Language Server
	["jsonls"] = function()
		require("lspconfig").jsonls.setup({
			capabilities = capabilities,
			filetypes = { "json", "jsonc" },
		})
	end,

	-- Python Language Server
	["pyright"] = function()
		require("lspconfig").pyright.setup({
			capabilities = capabilities,
			filetypes = { "python" },
		})
	end,

	-- Kotlin Language Server
	["kotlin_language_server"] = function()
		require("lspconfig").kotlin_language_server.setup({
			capabilities = capabilities,
			filetypes = { "kotlin" },
		})
	end,

	-- CSS Language Server
	["cssls"] = function()
		require("lspconfig").cssls.setup({
			capabilities = capabilities,
			filetypes = { "html", "htmlangular", "scss", "css" },
		})
	end,

	-- ESLint Language Server
	["eslint"] = function()
		require("lspconfig").eslint.setup({
			capabilities = capabilities,
			filetypes = { "typescript", "typescriptreact", "html", "htmlangular", "scss", "css" },
		})
	end,

	-- Tailwind CSS Language Server
	["tailwindcss"] = function()
		require("lspconfig").tailwindcss.setup({
			capabilities = capabilities,
			filetypes = { "html", "htmlangular", "scss", "css" },
		})
	end,

	-- Lua Language Server
	["lua_ls"] = function()
		require("lspconfig").lua_ls.setup({
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
	end,

	-- Angular Language Server
	["angularls"] = function()
		require("lspconfig").angularls.setup({
			capabilities = capabilities,
			filetypes = { "typescript", "html", "htmlangular", "typescriptreact", "typescript.tsx" },
			root_dir = lspconfig_util.root_pattern("package.json"),
		})
	end,
})

-- Additional keymaps for built-in commands
local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap
vim.api.nvim_set_keymap(
	"n",
	"<leader>t",
	":TSToolsFixAll<CR>:EslintFixAll<CR>:TSToolsAddMissingImports<CR>:TSToolsOrganizeImports<CR>",
	opts
)
map("n", "<leader>/", ":noh<CR>", opts)
map("n", "<leader>z", ":u<CR>", opts)
map("n", "<leader>y", ":red<CR>", opts)
map("n", "<leader>w", ":w<CR>", opts)
map("n", "<leader>ww", ":wall<CR>", opts)
