return {
  -- add black metal theme
  { "metalelf0/black-metal-theme-neovim" },

  -- Configure LazyVim to load black-metal theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "burzum",
    },
  },
  {
    "olrtg/nvim-emmet",
    config = function()
      vim.keymap.set({ "n", "v" }, "<leader>xe", require("nvim-emmet").wrap_with_abbreviation)
    end,
  },
}
