-- LSP capabilities with nvim-cmp
vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- Default keymaps on LSP attach (mirrors lsp-zero defaults)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'K',          vim.lsp.buf.hover,           opts)
    vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,      opts)
    vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,     opts)
    vim.keymap.set('n', 'gi',         vim.lsp.buf.implementation,  opts)
    vim.keymap.set('n', 'go',         vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr',         vim.lsp.buf.references,      opts)
    vim.keymap.set('n', 'gs',         vim.lsp.buf.signature_help,  opts)
    vim.keymap.set('n', '<F2>',       vim.lsp.buf.rename,          opts)
    vim.keymap.set('n', '<F4>',       vim.lsp.buf.code_action,     opts)
    vim.keymap.set('n', 'gl',         vim.diagnostic.open_float,   opts)
    vim.keymap.set('n', '[d',         vim.diagnostic.goto_prev,    opts)
    vim.keymap.set('n', ']d',         vim.diagnostic.goto_next,    opts)
    vim.keymap.set({'n','x'}, '<F3>', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

-- lua_ls: teach it about the neovim runtime
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

-- clangd: verbose logging
vim.lsp.config('clangd', {
  cmd = { 'clangd', '--log=verbose' },
})

-- WGSL: filetype detection + enable server
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.wgsl',
  command = 'setfiletype wgsl',
})
vim.lsp.config('wgsl_analyzer', {})

-- Mason: install servers
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'ts_ls',
    'eslint',
    'lua_ls',
    'rust_analyzer',
    'clangd',
    'pyright',
  },
  handlers = {
    function(server_name)
      vim.lsp.enable(server_name)
    end,
  },
})

-- Also enable servers not managed by mason
vim.lsp.enable('wgsl_analyzer')

-- nvim-cmp: Tab to confirm
local cmp = require('cmp')
cmp.setup({
  sources = { { name = 'nvim_lsp' } },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>']   = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
})

-- Diagnostic signs
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✘',
      [vim.diagnostic.severity.WARN]  = '▲',
      [vim.diagnostic.severity.HINT]  = '⚑',
      [vim.diagnostic.severity.INFO]  = '»',
    },
  },
})

-- Show diagnostics on hover
vim.api.nvim_create_autocmd('CursorHold', {
  callback = function()
    vim.diagnostic.open_float()
  end,
})

-- Format on save for Rust (when vim.g.format_on_save = true)
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.rs',
  callback = function()
    if vim.g.format_on_save then
      vim.lsp.buf.format({ async = false })
    end
  end,
})

-- Telescope
require('telescope').setup({
  pickers = {
    find_files = { follow = true },
  },
})
