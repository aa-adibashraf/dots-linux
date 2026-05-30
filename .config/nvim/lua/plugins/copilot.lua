-- File: lua/plugins/copilot.lua
-- Disable copilot-cmp (it requires nvim-cmp) and configure copilot.lua standalone.
-- Also tune suggestions so Copilot isn't intrusive or "on top".

return {
  -- 1) Make sure copilot-cmp is disabled to stop it from requiring 'cmp'
  {
    "zbirenbaum/copilot-cmp",
    enabled = false,
  },

  -- 2) Configure copilot.lua's own suggestion/panel UI
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      -- Keep Copilot separate from your completion menu (blink.cmp or nvim-cmp)
      suggestion = {
        enabled = true,
        auto_trigger = true, -- require manual trigger to avoid popping up instantly
        debounce = 200, -- slow down suggestion updates to be less intrusive
        keymap = {
          -- Choose non-conflicting keys (avoid <Tab> to keep it for your cmp menu)
          accept = "<M-Right>", -- Alt+Right to accept the whole suggestion
          accept_word = "<M-w>",
          accept_line = "<M-l>",
          next = "<M-]>", -- cycle copilot suggestions
          prev = "<M-[>",
          dismiss = "<M-d>",
        },
      },
      panel = {
        enabled = true,
        keymap = {
          open = "<M-p>",
          next = "<M-Down>",
          prev = "<M-Up>",
          accept = "<CR>",
          refresh = "r",
        },
      },
    },
  },

  -- 3) If you're using blink.cmp (LazyVim default now), ensure no Copilot source there.
  {
    "saghen/blink.cmp",
    optional = true, -- only applies if blink.cmp is installed
    opts = function(_, opts)
      -- Remove any copilot source entries if present
      if opts and opts.sources then
        local filtered = {}
        for _, src in ipairs(opts.sources) do
          if src.name ~= "copilot" then
            table.insert(filtered, src)
          end
        end
        opts.sources = filtered
      end
      return opts
    end,
  },

  -- 4) If you still use nvim-cmp instead of blink.cmp, make sure there's no copilot source there either.
  {
    "hrsh7th/nvim-cmp",
    optional = true, -- only applies if nvim-cmp is installed
    opts = function(_, opts)
      local cmp = require("cmp")
      -- Keep standard sources; do not include 'copilot'
      opts.sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 900 },
        { name = "buffer", priority = 700 },
        { name = "path", priority = 600 },
      })
      return opts
    end,
  },
}
