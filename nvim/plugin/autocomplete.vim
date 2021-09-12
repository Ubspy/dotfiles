lua <<EOF
    -- Set completeopt to have a better completion experience
    vim.o.completeopt = 'menuone,noselect'
    
    local cmp = require'cmp'
    cmp.setup({
     -- snippet = {
     --   expand = function(args)
     --     vim.fn["vsnip#anonymous"](args.body)
     --   end,
     -- },
      mapping = {
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
      },
      sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' }, 
      }
    })
EOF
