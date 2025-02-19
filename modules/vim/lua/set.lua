vim.opt.termguicolors = true

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 6
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.api.nvim_set_keymap('n', ':', '<cmd>FineCmdline<CR>', { noremap = true, silent = true })
vim.cmd[[colorscheme catppuccin]]
vim.cmd[[packadd termdebug]]

vim.cmd [[
  augroup ClangFormatBeforeSave
    autocmd!
    autocmd BufWritePost *.cpp,*.h,*.c,*.hpp :silent! !clang-format -i %
  augroup END
]]
