local lsp = require('lsp-zero').preset({})

lsp.ensure_installed({
  "tsserver", -- TypeScript
  "eslint", -- ESL JS linter
  "lua_ls", -- Lua
  "rust_analyzer", -- Rust
  "reason_ls", -- ReasonML
  "clangd",
  "java_language_server", -- Java
  "pyright" -- Python
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

-- Add Racket lang server manually (Mason doesnt have it, so make sure you have it installed yourself!!)
require('lspconfig').racket_langserver.setup{}

lsp.setup()
