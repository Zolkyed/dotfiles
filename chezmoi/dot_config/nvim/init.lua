-- LAZY VIM SETUP
-- Minimal Config Archebus Desktop

---------------------------------------
--          LAZY NVIM
---------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

---------------------------------------
--          GENERAL SETTINGS
---------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.colorcolumn = ""

-- Transparency
vim.opt.termguicolors = true
vim.opt.winblend = 10
vim.opt.pumblend = 10

-- Leader key
vim.g.mapleader = " "

require("lazy").setup({

---------------------------------------
--            THEMES
---------------------------------------

	-- Theme dumps I like
	{
	    "andreasvc/vim-256noir",
        "webhooked/kanso.nvim",
        "yonlu/omni.vim",
        "mcauley-penney/techbase.nvim",
        "nyoom-engineering/oxocarbon.nvim",
        "miikanissi/modus-themes.nvim",
        "hyperb1iss/silkcircuit-nvim",
	},
    
    -- Catpuccin (most popular nvim theme)
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

	-- Darkvoid Theme /w specific options.
	{
	    "aliqyan-21/darkvoid.nvim",
	    config = function()
	        require("darkvoid").setup({
	            transparent = true,
	            glow = true,
	            show_end_of_buffer = true, 
	        })
        end,
	},

---------------------------------------
--            PLUGINS
---------------------------------------

    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "rust_analyzer" },
            })
            
            -- New way using vim.lsp.config
            vim.lsp.config('rust_analyzer', {
                cmd = { 'rust-analyzer' },
                root_markers = { 'Cargo.toml' },
                settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = true,
                    },
                },
            })
            
            vim.lsp.enable('rust_analyzer')
        end,
    },

    -- Git Signs
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns
                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end
                    
                    map("n", "]c", function()
                        if vim.wo.diff then return "]c" end
                        vim.schedule(function() gs.next_hunk() end)
                        return "<Ignore>"
                    end, {expr=true})
                    
                    map("n", "[c", function()
                        if vim.wo.diff then return "[c" end
                        vim.schedule(function() gs.prev_hunk() end)
                        return "<Ignore>"
                    end, {expr=true})
                    
                    map("n", "<leader>hs", gs.stage_hunk)
                    map("n", "<leader>hr", gs.reset_hunk)
                    map("n", "<leader>hp", gs.preview_hunk)
                    map("n", "<leader>hb", function() gs.blame_line{full=true} end)
                end
            })
        end,
    },

    -- Toggle Term (floating term)
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4  -- 40% of screen width
                    end
                end,
                open_mapping = [[<c-\>]],
                hide_numbers = true,
                shade_terminals = false,  -- Disable shading for splits
                start_in_insert = true,
                insert_mappings = true,
                terminal_mappings = true,
                persist_size = true,
                persist_mode = true,
                direction = "vertical",  -- Default to vertical split
                close_on_exit = true,
                shell = vim.o.shell,
            })

            -- Function to get current buffer's directory
            local function get_current_dir()
                local current_file = vim.fn.expand('%:p')
                if current_file == '' then
                    return vim.fn.getcwd()  -- Fallback to current working directory
                else
                    return vim.fn.fnamemodify(current_file, ':h')  -- Get directory of current file
                end
            end

            -- Custom terminal that opens in current directory
            local Terminal = require("toggleterm.terminal").Terminal
            
            -- Vertical split terminal in current directory
            local vsplit_term = nil
            function _VSPLIT_TOGGLE()
                if vsplit_term == nil or not vsplit_term:is_open() then
                    vsplit_term = Terminal:new({
                        direction = "vertical",
                        dir = get_current_dir(),
                        on_open = function(term)
                            vim.cmd("startinsert!")
                        end,
                    })
                end
                vsplit_term:toggle()
            end

            -- Horizontal split terminal in current directory
            local hsplit_term = nil
            function _HSPLIT_TOGGLE()
                if hsplit_term == nil or not hsplit_term:is_open() then
                    hsplit_term = Terminal:new({
                        direction = "horizontal",
                        dir = get_current_dir(),
                        on_open = function(term)
                            vim.cmd("startinsert!")
                        end,
                    })
                end
                hsplit_term:toggle()
            end

            -- Floating terminal in current directory
            local float_term = nil
            function _FLOAT_TOGGLE()
                if float_term == nil or not float_term:is_open() then
                    float_term = Terminal:new({
                        direction = "float",
                        dir = get_current_dir(),
                        float_opts = {
                            border = "curved",
                            width = math.floor(vim.o.columns * 0.8),
                            height = math.floor(vim.o.lines * 0.8),
                        },
                        on_open = function(term)
                            vim.cmd("startinsert!")
                        end,
                    })
                end
                float_term:toggle()
            end

            -- Keymaps
            vim.keymap.set("n", "<leader>tv", "<cmd>lua _VSPLIT_TOGGLE()<CR>", { desc = "Toggle vertical terminal" })
            vim.keymap.set("n", "<leader>th", "<cmd>lua _HSPLIT_TOGGLE()<CR>", { desc = "Toggle horizontal terminal" })
            vim.keymap.set("n", "<leader>tf", "<cmd>lua _FLOAT_TOGGLE()<CR>", { desc = "Toggle floating terminal" })
            
            -- Quick terminal commands in current directory
            vim.keymap.set("n", "<leader>tg", function()
                local term = Terminal:new({
                    cmd = "lazygit",
                    direction = "float",
                    dir = get_current_dir(),
                    float_opts = {
                        border = "curved",
                        width = math.floor(vim.o.columns * 0.9),
                        height = math.floor(vim.o.lines * 0.9),
                    },
                    on_exit = function()
                        vim.cmd("checktime")  -- Refresh buffers after git operations
                    end,
                })
                term:toggle()
            end, { desc = "LazyGit in current dir" })

            -- Exit terminal mode with Esc
            vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
            vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { desc = "Go to left window" })
            vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { desc = "Go to lower window" })
            vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { desc = "Go to upper window" })
            vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { desc = "Go to right window" })
        end,
	},

    -- None-ls (formatting and linting)
    {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.rustfmt,
                    null_ls.builtins.formatting.prettier,
                    null_ls.builtins.formatting.shfmt,
                    null_ls.builtins.diagnostics.shellcheck,
                    null_ls.builtins.code_actions.shellcheck,
                },
            })
            
            vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format, { desc = "Format buffer" })
        end,
    },

    -- Lualine (bottom satus bar)
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,
                },
                sections = {
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" }
                },
            })
        end,
    },

	-- Treesitter for syntax highlighting
	{
	    "nvim-treesitter/nvim-treesitter",
	    build = ":TSUpdate",
	    config = function()
	        require("nvim-treesitter.configs").setup({
		        ensure_installed = { "rust", "lua", "vim" },
		        highlight = { enable = true },
		        indent = { enable = true },
	        })
	    end,
	},

	-- Autocompletion
	{
	    "hrsh7th/nvim-cmp",
	    dependencies = {
		    "hrsh7th/cmp-nvim-lsp",
		    "hrsh7th/cmp-buffer",
		    "hrsh7th/cmp-path",
		    "L3MON4D3/LuaSnip",
		    "saadparwaiz1/cmp_luasnip",
	    },
	    config = function()
	        local cmp = require("cmp")
	        cmp.setup({
		        snippet = {
		            expand = function(args)
		                require("luasnip").lsp_expand(args.body)
		            end,
		        },

		        mapping = cmp.mapping.preset.insert({
		            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
		            ["<C-f>"] = cmp.mapping.scroll_docs(4),
		            ["<C-Space>"] = cmp.mapping.complete(),
		            ["<CR>"] = cmp.mapping.confirm({ select = true }),
		        }),

		        sources = cmp.config.sources({
		            { name = "nvim_lsp" },
		            { name = "luasnip" },
		        }, {
		            { name = "buffer" },
		        }),
	        })
	    end,
	},

	-- File explorer
	{
	    "nvim-tree/nvim-tree.lua",
	    dependencies = { "nvim-tree/nvim-web-devicons" },
	    config = function()
	        require("nvim-tree").setup()
	        vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
	    end,
	},

	-- Fuzzy finder
	{
	    "nvim-telescope/telescope.nvim",
	    dependencies = { "nvim-lua/plenary.nvim" },
	    config = function()
	        local telescope = require("telescope")
	        telescope.setup()
	        local builtin = require("telescope.builtin")
	        vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
	        vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
	        vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
	    end,
	},
})

---------------------------------------
--      THEME SETUP + TRANSPARENCY
---------------------------------------
-- Force transparency for all colorschemes
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
    end,
})

-- Apply transparency to current colorscheme immediately
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

vim.cmd.colorscheme("default")

---------------------------------------
--          KEY MAPPINGS
---------------------------------------
-- General key mappings
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
	
-- LSP key mappings
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local opts = { buffer = args.buf }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    end,
})

-- Window Navigation
vim.keymap.set("n", "<C-Left>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-Up>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { desc = "Go to right window" })

-- Window Management
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close current split" })

-- Terminal Navigation
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-Left>", [[<C-\><C-n><C-w>h]], { desc = "Go to left window" })
vim.keymap.set("t", "<C-Down>", [[<C-\><C-n><C-w>j]], { desc = "Go to lower window" })  
vim.keymap.set("t", "<C-Up>", [[<C-\><C-n><C-w>k]], { desc = "Go to upper window" })
vim.keymap.set("t", "<C-Right>", [[<C-\><C-n><C-w>l]], { desc = "Go to right window" })
