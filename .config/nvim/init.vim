call plug#begin('~/.vim/plugged')

" List the plugins you want to install here, for example:
Plug 'tpope/vim-sensible'
Plug 'https://github.com/leafgarland/typescript-vim'
Plug 'https://github.com/Quramy/vim-js-pretty-template'
Plug 'https://github.com/pangloss/vim-javascript'
Plug 'https://github.com/Shougo/vimproc.vim', {'do' : 'make'}
Plug 'nvim-lua/plenary.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'https://github.com/pmizio/typescript-tools.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug '3rd/image.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-tree/nvim-web-devicons'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'https://github.com/lewis6991/gitsigns.nvim'
Plug 'https://github.com/tpope/vim-fugitive'
Plug 'https://github.com/Isrothy/neominimap.nvim'
Plug 'https://github.com/lewis6991/satellite.nvim'
Plug 'https://github.com/jmbuhr/otter.nvim'
Plug 'https://github.com/monkoose/neocodeium'
Plug 'https://github.com/scottmckendry/cyberdream.nvim'
Plug 'https://github.com/tomiis4/Hypersonic.nvim'
Plug 'michaelb/sniprun', {'do': 'sh ./install.sh'}
Plug 'https://github.com/tpope/vim-commentary'
Plug 'https://github.com/lewis6991/hover.nvim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'rafamadriz/friendly-snippets'
Plug 'https://github.com/morhetz/gruvbox'
Plug 'https://github.com/rktjmp/lush.nvim'
Plug 'https://github.com/nmac427/guess-indent.nvim'
Plug 'https://github.com/shellRaining/hlchunk.nvim'
Plug 'stevearc/dressing.nvim'
Plug 'mfussenegger/nvim-dap'
Plug 'akinsho/toggleterm.nvim'
Plug 'kylechui/nvim-surround'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'windwp/nvim-ts-autotag'
Plug 'https://github.com/luckasRanarison/tailwind-tools.nvim'
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }
Plug 'hail2u/vim-css3-syntax'
Plug 'roobert/tailwindcss-colorizer-cmp.nvim'
Plug 'https://github.com/onsails/lspkind.nvim'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'kdheepak/lazygit.nvim'
call plug#end()

filetype plugin indent on
set number
set ts=4
set sw=4
set so=8
set background=dark
set lcs=tab:▏\
set showtabline=2
set laststatus=2
set scrolloff=8
set wildmenu
set nowrap
set timeoutlen=200
let g:mapleader = " "
syntax on
set nofoldenable
set fdm=syntax

if (empty($TMUX) && getenv('TERM_PROGRAM') != 'Apple_Terminal')
  if (has("nvim"))
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  if (has("termguicolors"))
    set termguicolors
  endif
endif

lua << EOF
vim.cmd("colorscheme gruvbox")

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
require("tailwind-tools").setup()
require'colorizer'.setup()
vim.cmd([[let g:vsnip_snippet_dir = '~/.config/nvim/snippets']]) 
require("nvim-surround").setup()
require('telescope').setup()
require('telescope').load_extension('fzf')
require('gitsigns').setup()
require('satellite').setup()
require'nvim-web-devicons'.setup()
require('hypersonic').setup()
require('toggleterm').setup()
require("cmp").config.formatting = {
  format = require("tailwindcss-colorizer-cmp").formatter
}
require('neo-tree').setup({
	close_if_last_window = true,
	popup_border_style = "rounded",
	enable_git_status = true,
	enable_diagnostics = true,
	use_libuv_file_watcher = true,
	follow_current_file = {
		enable = false,
		leave_dirs_open = false
	}
})
  require('tailwindcss-colorizer-cmp').setup({
    color_square_width = 2,
  })
require('nvim-ts-autotag').setup({
  opts = {
    -- Defaults
    enable_close = true,
    enable_rename = true,
    enable_close_on_slash = true
  },
  per_filetype = {
    ["html"] = {
      enable_close = false
    }
  }
})
require("typescript-tools").setup{}

require("neocodeium").setup()
require("hover").setup {
	require("hover.providers.lsp")
}
require('guess-indent').setup {}
require('hlchunk').setup({
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
        enable = true
    },
    blank = {
	enable = true
    }
})
local cmp = require'cmp'
cmp.setup({
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' },
	}, {
		{ name = "path" },
    { name = 'tailwind_tools' },
	})
})

cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	}),
	matching = { disallow_symbol_nonprefix_matching = false }
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "angularls", -- Angular HTML/TS LSP
        "cssls",     -- CSS LSP
        "tailwindcss", -- TailwindCSS LSP
        "jsonls",    -- JSON LSP
        "eslint",    -- ESLint LSP
        "lua_ls",    -- Lua LSP (for Neovim configurations)
    },
    automatic_installation = true,
})
local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
lspconfig.tailwindcss.setup {
    capabilities = capabilities,
}
lspconfig.jsonls.setup {
    capabilities = capabilities,
}
lspconfig.eslint.setup {
    capabilities = capabilities,
}
lspconfig.lua_ls.setup {
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
                },
        },
    },
}
lspconfig.angularls.setup {
  cmd = { "ngserver", "--stdio" },
  on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    -- Add the keymap for <leader>g
    buf_set_keymap('n', '<leader>g', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap=true, silent=true })
  end,
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = {
      "ngserver",
      "--stdio",
      "--tsProbeLocations", new_root_dir,
      "--ngProbeLocations", new_root_dir
    }
  end,
  filetypes = { "typescript", "html" },
  root_dir = require('lspconfig').util.root_pattern("angular.json", ".git")
}

lspconfig.cssls.setup {
    capabilities = capabilities,

}



vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
vim.keymap.set("i", "<A-g>", require("neocodeium").accept)
vim.keymap.set({ "n" }, "-", ":Neotree reveal position=left toggle<cr>",
	{ desc = "Toggle neotree" })

map('n', '<leader>gg', ':LazyGit<CR>', opts)
map('n', '<C-z>', ':u<CR>', opts)
map('n', '<C-g>', ':Telescope find_files<CR>', opts)
map('n', '<C-f>', ':Telescope live_grep<CR>', opts)
map('n', '<C-y>', ':red<CR>', opts)
map('n', '=', ':ToggleTerm size=15 direction=horizontal <CR>', opts )
map('t', '<C-t>',[[<C-\><C-n><C-w>k]], opts)

EOF
