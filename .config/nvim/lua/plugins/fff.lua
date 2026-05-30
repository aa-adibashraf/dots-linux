return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false,
  init = function()
    -- fff.nvim reads this global option for its border shapes
    -- Using "rounded" will give us a single thin line border with rounded corners
    pcall(function() vim.o.winborder = "rounded" end)

    -- Define a custom border highlight group with a subtle dark color
    -- Setting bg = "NONE" ensures it doesn't look like a thick gray block!
    local function set_fff_hl()
      -- #333333 is a good subtle dark gray, you can change to #121212 if you want it even darker
      vim.api.nvim_set_hl(0, "FFFBorder", { fg = "#333333", bg = "NONE" })
    end
    set_fff_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_fff_hl,
    })
  end,
  opts = {
    debug = {
      enabled = true,
      show_scores = false,
    },
    history = {
      enabled = true,
    },
    layout = {
      prompt_position = "top",
    },
    hl = {
      -- We leave normal out to keep your transparent background,
      -- but map the border to our custom #121212 highlight group
      border = "FFFBorder",
      title = "FloatTitle",
    },
  },
  keys = {
    { "<leader><space>", function() require("fff").find_files() end, desc = "Find Files (FFF)" },
    { "<leader>ff", function() require("fff").find_files() end, desc = "Find Files (FFF)" },
    { "<leader>fg", function() require("fff").live_grep() end, desc = "Live Grep (FFF)" },
    { "<leader>f/", function() require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } }) end, desc = "Live Fuzzy Grep (FFF)" },
    { "<leader>fw", function() require("fff").live_grep({ query = vim.fn.expand("<cword>") }) end, desc = "Search Current Word (FFF)" },
    { "<leader>fs", function() require("fff").scan_files() end, desc = "Rescan/Index Files (FFF)" },
  },
}