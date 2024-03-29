local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local is_not_a_directory = vim.fn.isdirectory(plenary_dir) == 0
if is_not_a_directory then
	vim.fn.system({ "git", "clone", "https://github.com/nvim-lua/plenary.nvim", plenary_dir })
end

local which_key_dir = "/tmp/nvim-which-key"
is_not_a_directory = vim.fn.isdirectory(which_key_dir) == 0
if is_not_a_directory then
	vim.fn.system({ "git", "clone", "https://github.com/folke/which-key.nvim", which_key_dir })
end

vim.opt.rtp:append(".")
vim.opt.rtp:append(plenary_dir)
vim.opt.rtp:append(which_key_dir)

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
require("tests.assert_extra")
