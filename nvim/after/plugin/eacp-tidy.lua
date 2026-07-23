-- eacp repo: surfaces the eacp-* clang-tidy plugin checks as diagnostics.
-- clangd can't load clang-tidy plugins (clangd/clangd#1458), so this runs
-- the repo's plugin-loaded clang-tidy on open/save. Harmless when the repo
-- isn't checked out. See eacp/ExtraClangRules/README.md.
local bridge =
    vim.fn.expand("~/projects/eacp/ExtraClangRules/nvim/eacp-tidy.lua")
if vim.uv.fs_stat(bridge) then
    dofile(bridge).setup()
end
