return {
  "mikavilpas/yazi.nvim",
  version = "*",
  lazy = false,
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    {
      "<leader>e",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      "<leader>E",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
    {
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  ---@type YaziConfig | {}
  opts = {
    open_for_directories = true,
    keymaps = {
      show_help = "<f1>",
    },
    hooks = {
      yazi_closed_successfully = function()
        -- After yazi closes from an auto-opened directory, restore the dashboard
        local buf = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_get_name(buf) == "" then
          require("snacks").dashboard()
        end
      end,
    },
  },
  init = function()
    vim.g.loaded_netrwPlugin = 1
  end,
}
