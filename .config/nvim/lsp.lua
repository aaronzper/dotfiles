-- LSP capabilities with nvim-cmp
vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- Peek definition: floating preview (styled like the Telescope pickers),
-- closeable with :q or by leaving the window (Ctrl-W / gt), promotable to a
-- real split/vsplit/tab with Ctrl-X/V/T (same keys Telescope uses).
local function peek_definition()
  local params = vim.lsp.util.make_position_params(0, nil)
  vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result)
    if err or not result or vim.tbl_isempty(result) then
      vim.notify('No definition found', vim.log.levels.INFO)
      return
    end
    local loc = result[1] or result
    local uri = loc.uri or loc.targetUri
    local range = loc.range or loc.targetSelectionRange or loc.targetRange
    local fname = vim.uri_to_fname(uri)
    local src_bufnr = vim.uri_to_bufnr(uri)
    vim.fn.bufload(src_bufnr)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.api.nvim_buf_get_lines(src_bufnr, 0, -1, false))
    vim.bo[buf].filetype = vim.bo[src_bufnr].filetype
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = 'wipe'

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.6)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      style = 'minimal',
      border = 'rounded',
      title = ' ' .. vim.fn.fnamemodify(fname, ':.') .. ' ',
      title_pos = 'center',
    })
    vim.wo[win].winhighlight = 'Normal:Normal,NormalFloat:Normal'
    vim.api.nvim_win_set_cursor(win, { range.start.line + 1, range.start.character })
    vim.api.nvim_win_call(win, function() vim.cmd('normal! zz') end)

    local function close()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end

    vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
      buffer = buf,
      once = true,
      callback = close,
    })

    local function open_in(cmd)
      return function()
        close()
        vim.cmd(cmd .. ' ' .. vim.fn.fnameescape(fname))
        vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
        vim.cmd('normal! zz')
      end
    end

    local map_opts = { buffer = buf, nowait = true, silent = true }
    vim.keymap.set('n', '<C-x>', open_in('split'),   map_opts)
    vim.keymap.set('n', '<C-v>', open_in('vsplit'),  map_opts)
    vim.keymap.set('n', '<C-t>', open_in('tabedit'), map_opts)
    vim.keymap.set('n', 'q',     close,               map_opts)
    vim.keymap.set('n', '<Esc>', close,               map_opts)
  end)
end

-- Default keymaps on LSP attach (mirrors lsp-zero defaults)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'K',          vim.lsp.buf.hover,           opts)
    vim.keymap.set('n', 'gd',         peek_definition,              opts)
    vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,     opts)
    vim.keymap.set('n', 'gi',         vim.lsp.buf.implementation,  opts)
    vim.keymap.set('n', 'go',         vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr',         function()
      require('telescope.builtin').lsp_references({
        show_line = false,
        layout_config = { preview_width = 0.6 },
      })
    end,                                                            opts)
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

-- rust-analyzer: enable proc-macro expansion and build script eval
vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      procMacro = { enable = true },
      cargo = { buildScripts = { enable = true } },
    },
  },
})

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
