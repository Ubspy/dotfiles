require("autoclose").setup({
    -- Example:
    -- [">"] = { escape = false, close = false, pair = "<>", disabled_filetypes = {} },
    keys = {
        ["'"] = { escape = true, close = true, pair = "aa", disabled_filetypes = { "tex" } },
    },
    options = {
        disabled_filetypes = { "text", "markdown" }
    }
})

-- More at:
-- https://github.com/m4xshen/autoclose.nvim
