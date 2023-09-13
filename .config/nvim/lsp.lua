local lsp = require('lsp-zero').preset({})

lsp.ensure_installed({
  "tsserver",
  "eslint-lsp",
  "lua_ls",
  "rust_analyzer",
  "reason_ls",
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

-- Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

-- Add Racket lang server manually (Mason doesnt have it, so make sure you have it installed yourself!!)
require('lspconfig').racket_langserver.setup{}

lsp.setup()
