local slimline = require('slimline')
local C = {}
local config = slimline.config.configs.progress

---@param opts render.options
---@return string
function C.render(opts)
  local total = vim.fn.line('$')
  local position = string.format("%d:%d", vim.fn.line('.'), vim.fn.col('.'))
  local primary = string.format('%s %s / %s', config.icon, position, total)

  return slimline.highlights.hl_component(
    { primary = primary, secondary = '' },
    opts.hls,
    opts.sep,
    opts.direction,
    opts.active
  )
end

return C
