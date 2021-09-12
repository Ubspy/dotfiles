lua << EOF
# Add rust language server
require'lspconfig'.rust_analyzer.setup{}
EOF

" Add lightbulbs on the side if there are actions to take
autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
