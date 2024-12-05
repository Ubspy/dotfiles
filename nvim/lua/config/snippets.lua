-- Import LuaSnip
local ls = require('luasnip')

-- Shorthands for convenience
local snip = ls.snippet
local node = ls.snippet_node
local text = ls.text_node
local insert = ls.insert_node
local func = ls.function_node
local choice = ls.choice_node
local dynamicn = ls.dynamic_node

-- Latex snippets
ls.add_snippets("tex", {
    snip("begin", {
        -- When this macro is triggered, it will type out "\begin{" in the tex file,
        -- then, it will also put "\end{" after a newline, whatever environment
        -- is typed into the begin section will also be copied to the end section 
        text("\\begin{"), insert(1, "env"), text("}\n\\end{"), insert(1, "env"),
            text("}")
    })
})

-- Github page for more:
-- https://github.com/L3MON4D3/LuaSnip
