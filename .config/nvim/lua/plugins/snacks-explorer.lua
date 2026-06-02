return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.explorer = vim.tbl_deep_extend("force", opts.explorer or {}, {
        replace_netrw = false,
      })
    end,
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
    },
  },
}
