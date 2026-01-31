local M = {}

local log = function(...)
  --
  -- print('[DEBUG] awmc:', ...)
end

M.log = log

M.throw = function(msg) error('[ERROR] awmc: ' .. msg) end

M.get_resource_path = function(name)
  local info = debug.getinfo(1, 'S')
  local rootdir =
    vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(info.source:gsub('^@', ''))))
  log('rootdir:', rootdir)
  return vim.fs.joinpath(rootdir, 'resources', name)
end

return M
