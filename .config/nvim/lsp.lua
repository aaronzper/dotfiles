local lsp = require('lsp-zero').preset({})

lsp.ensure_installed({
  "ts_ls",                -- TypeScript
  "eslint",               -- ESL JS linter
  "lua_ls",               -- Lua
  "rust_analyzer",        -- Rust
  "clangd",               -- Clang
  "java_language_server", -- Java
  "pyright",              -- Python
  -- "some-sass-langauge-server", -- SCSS/SASS
})

local cmp = require("cmp")
local cmp_mappings = lsp.defaults.cmp_mappings({
  ["<Tab>"] = cmp.mapping.confirm({ select = true }), -- Confirm completion with <Tab>
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.on_attach(function(_, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

-- Show these icons instead of just W or E or whatever on the lefthand side
lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

-- Show errors/warnings/etc on hover (can do so manually via <gl>)
vim.cmd('autocmd CursorHold * lua vim.diagnostic.open_float()')

-- Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()
