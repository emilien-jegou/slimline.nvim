local slimline = require('slimline')
local C = {}
local config = slimline.config.configs.path
---@param path string
---@return string
local function shrink_path(path)
  -- Calculate maximum path length based on terminal width
  local max_path_length = vim.o.columns - 40 -- this is a magic number!
  
  if #path <= max_path_length then
    return path
  end
  
  -- Split path into components
  local path_parts = vim.split(path, '/', { plain = true })
  local filename = path_parts[#path_parts]
  
  -- If we only have a filename, return it
  if #path_parts <= 1 then
    return path
  end
  
  -- Start with just the filename and ellipsis
  local ellipsis = '…/'
  local result = ellipsis .. filename
  
  -- Try to add directory parts from the beginning while staying under limit
  for i = 1, #path_parts - 1 do
    local prefix = table.concat(path_parts, '/', 1, i) .. '/' .. ellipsis .. filename
    
    if #prefix <= max_path_length then
      result = prefix
    else
      break
    end
  end
  
  return result
end
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
    local secondary = ''
    if vim.bo.modified then secondary = secondary .. ' ' end
    return slimline.highlights.hl_component(
      { primary = project_name, secondary = secondary },
      opts.hls,
      opts.sep,
      opts.direction,
      opts.active
    )
  end
  
  -- Shrink the path if it's too long (before adding indicators)
  local display_path = shrink_path(relative_path)
  
  -- Add modified/readonly indicators to the display path
  if vim.bo.modified then display_path = display_path .. ' ' end
  if vim.bo.readonly then display_path = display_path .. ' ' .. config.icons.read_only end
  
  -- Render the components
  return slimline.highlights.hl_component(
    { primary = project_name, secondary = display_path },
    opts.hls,
    opts.sep,
    opts.direction,
    opts.active
  )
end
return C
