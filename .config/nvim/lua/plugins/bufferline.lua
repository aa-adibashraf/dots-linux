return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
    { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
    { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
    { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
    { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
  },
  opts = {
    highlights = {
      -- The background strip behind all tabs
      fill = {
        bg = "#0D0D0D",
      },
      -- Inactive tab
      background = {
        fg = "#8A8A8D",
        bg = "#212121",
      },
      -- Inactive tab separator (slope between inactive tabs)
      separator = {
        fg = "#0D0D0D",
        bg = "#212121",
      },
      -- Inactive tab that is visible (non-focused split)
      buffer_visible = {
        fg = "#BEBEBE",
        bg = "#262626",
      },
      separator_visible = {
        fg = "#0D0D0D",
        bg = "#262626",
      },
      -- Active/selected tab — amber accent matching tmux session widget
      buffer_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
        bold = true,
      },
      separator_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      -- Diagnostic indicators
      error = {
        fg = "#DC2626",
        bg = "#212121",
      },
      error_visible = {
        fg = "#DC2626",
        bg = "#262626",
      },
      error_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      error_diagnostic = {
        fg = "#DC2626",
        bg = "#212121",
      },
      error_diagnostic_visible = {
        fg = "#DC2626",
        bg = "#262626",
      },
      error_diagnostic_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      warning = {
        fg = "#D97706",
        bg = "#212121",
      },
      warning_visible = {
        fg = "#D97706",
        bg = "#262626",
      },
      warning_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      warning_diagnostic = {
        fg = "#D97706",
        bg = "#212121",
      },
      warning_diagnostic_visible = {
        fg = "#D97706",
        bg = "#262626",
      },
      warning_diagnostic_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      info = {
        fg = "#3B82F6",
        bg = "#212121",
      },
      info_visible = {
        fg = "#3B82F6",
        bg = "#262626",
      },
      info_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      info_diagnostic = {
        fg = "#3B82F6",
        bg = "#212121",
      },
      info_diagnostic_visible = {
        fg = "#3B82F6",
        bg = "#262626",
      },
      info_diagnostic_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      hint = {
        fg = "#1EA7A0",
        bg = "#212121",
      },
      hint_visible = {
        fg = "#1EA7A0",
        bg = "#262626",
      },
      hint_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      hint_diagnostic = {
        fg = "#1EA7A0",
        bg = "#212121",
      },
      hint_diagnostic_visible = {
        fg = "#1EA7A0",
        bg = "#262626",
      },
      hint_diagnostic_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      diagnostic = {
        fg = "#8A8A8D",
        bg = "#212121",
      },
      diagnostic_visible = {
        fg = "#8A8A8D",
        bg = "#262626",
      },
      diagnostic_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      -- Modified indicator (dot when unsaved)
      modified = {
        fg = "#F59E0B",
        bg = "#212121",
      },
      modified_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      -- Tab close button
      close_button = {
        fg = "#8A8A8D",
        bg = "#212121",
      },
      close_button_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
      },
      -- Buffer number
      numbers = {
        fg = "#8A8A8D",
        bg = "#212121",
      },
      numbers_selected = {
        fg = "#0D0D0D",
        bg = "#F59E0B",
        bold = true,
      },
    },
    options = {
      -- stylua: ignore
      close_command = function(n) Snacks.bufdelete(n) end,
      -- stylua: ignore
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
      themable = true,
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      diagnostics_indicator = function(_, _, diag)
        local icons = LazyVim.config.icons.diagnostics
        local ret = (diag.error and icons.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.Warn .. diag.warning or "")
        return vim.trim(ret)
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          highlight = "Directory",
          text_align = "left",
        },
        {
          filetype = "snacks_layout_box",
        },
      },
      separator_style = "slope",

      ---@param opts bufferline.IconFetcherOpts
      get_element_icon = function(opts)
        return LazyVim.config.icons.ft[opts.filetype]
      end,
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    -- vim.cmd([[highlight BufferLineFill guibg=#1C1B1A]])
    -- Fix bufferline when restoring a session
    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
      callback = function()
        vim.schedule(function()
          pcall(nvim_bufferline)
        end)
      end,
    })
  end,
}
