local slimline = require('slimline')
local C = {}

local config = slimline.config.configs.path

---@param opts render.options
---@return string
function C.render(opts)
  -- Ignore special buffers like help, terminal, etc.
  if vim.bo.buftype ~= '' then return '' end

  -- 1. PRIMARY: The active project directory name. This is correct.
  local cwd = vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(cwd, ':t')

  -- 2. SECONDARY: The path of the file relative to the current working directory.
  --    The `:.` modifier is the most direct and reliable way to get this.
  local relative_path = vim.fn.expand('%:.')

  -- Handle unnamed buffers. For them, `expand('%:.')` returns an empty string.
  if relative_path == '' then
    local secondary = '[No Name]'
    if vim.bo.modified then secondary = secondary .. ' ' end
    return slimline.highlights.hl_component(
      { primary = project_name, secondary = secondary },
      opts.hls,
      opts.sep,
      opts.direction,
      opts.active
    )
  end

  -- Add modified/readonly indicators to the relative path
  if vim.bo.modified then relative_path = relative_path .. ' ' end
  if vim.bo.readonly then relative_path = relative_path .. ' ' .. config.icons.read_only end

  -- Render the components
  return slimline.highlights.hl_component(
    { primary = project_name, secondary = relative_path },
    opts.hls,
    opts.sep,
    opts.direction,
    opts.active
  )
end

return C
