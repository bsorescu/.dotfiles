return {
  -- LSP completion source for nvim-cmp
  {
    "hrsh7th/cmp-nvim-lsp",
  },

  -- LuaSnip and related dependencies
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip", -- LuaSnip source for nvim-cmp
      "rafamadriz/friendly-snippets", -- Predefined snippets
      "hrsh7th/cmp-buffer", -- Buffer completions
      "hrsh7th/cmp-path", -- Path completions
      "hrsh7th/cmp-vsnip", -- Snippet completions
      "hrsh7th/vim-vsnip", -- Snippet engine
    },
  },

  -- Emmet for HTML and CSS abbreviation expansions
  {
    "mattn/emmet-vim",
    config = function()
      vim.g.user_emmet_leader_key = "<C-y>" -- Trigger Emmet with Ctrl-y
    end,
  },

  -- Startify for creating templates (includes skeleton HTML support)
  {
    "mhinz/vim-startify",
    config = function()
      vim.api.nvim_create_autocmd("BufNewFile", {
        pattern = "*.html",
        callback = function()
          vim.cmd("0r ~/.config/nvim/templates/html.skeleton")
        end,
      })
    end,
  },

  -- GitHub Copilot plugin
  {
    "github/copilot.vim",
  },

  -- Autocompletion engine and its configuration
  {
    "hrsh7th/nvim-cmp",
    enabled = true,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
      "saadparwaiz1/cmp_luasnip", -- LuaSnip source for nvim-cmp
      "hrsh7th/cmp-buffer", -- Buffer completions
      "hrsh7th/cmp-path", -- Path completions
    },
    config = function()
      local cmp = require("cmp")
      require("luasnip.loaders.from_vscode").lazy_load() -- Load snippets from VSCode

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- LSP completion source
          { name = "luasnip" }, -- LuaSnip completion source
        }, {
          { name = "buffer" }, -- Buffer completions
        }),
      })
    end,
  },
}
