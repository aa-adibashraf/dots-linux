return {
  { "kepano/flexoki-neovim", name = "flexoki" },
  {
    "tahayvr/matteblack.nvim",
    opts = {
      transparent_mode = true,
      styles = {
        sidebars = "transparent",
        -- floats = "transparent",
        keywords = { "italic" },
      },
      on_highlights = function(colors)
        return {
          BufferLineSeparator = { fg = colors.bg, bg = colors.bg },
          BufferLineTabSeparator = { fg = colors.bg, bg = colors.bg },
          BufferLineSeparatorSelected = { fg = colors.bg, bg = colors.bg },
          BufferLineSeparatorVisible = { fg = colors.bg, bg = colors.bg },
        }
      end,
    },
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("matteblack")
    end,
  },
  { "yorumicolors/yorumi.nvim" },
  { "bettervim/yugen.nvim" },
  { "dasupradyumna/midnight.nvim" },
  { "rktjmp/lush.nvim" },
  { "metalelf0/jellybeans-nvim" },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    -- opts = {
    --   transparent = true,
    -- },
    -- config = function()
    --   vim.cmd.colorscheme("cyberdream")
    -- end,
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "cyberdream",
    },
  },
}
