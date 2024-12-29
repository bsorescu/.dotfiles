-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.o.clipboard = "unnamedplus"

--vim.api.nvim_create_user_command("LiveServer", function()
--  local cmd = "live-server ."
--  vim.fn.jobstart(cmd, { detach = true })
--  print("Live Server started at http://127.0.0.1:8080")
--end, {})

vim.api.nvim_create_user_command("LiveServer", function()
  local cmd = "browser-sync start --server --files='**/*.html, **/*.css, **/*.js'"
  vim.fn.jobstart(cmd, { detach = true })
  print("Browser Sync started at http://localhost:3000")
end, {})

vim.api.nvim_create_user_command("StopServer", function()
  vim.fn.system("pkill browser-sync")
  print("Browser Sync stopped.")
end, {})

vim.api.nvim_set_keymap("n", "<leader>ls", ":LiveServer<CR>", { noremap = true, silent = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.html",
  callback = function()
    vim.cmd("LiveServer")
  end,
})

vim.api.nvim_create_user_command("LiveServer", function()
  vim.cmd("split term://live-server .")
end, {})
--vim.opt.clipboard = "unnamedplus"
