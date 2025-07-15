-- File: lua/my_slimline_components/lsp_spinner.lua

local C = {}
local initialized = false
local slimline

-- --- State Variables ---
-- This will hold the final, formatted string for the component, just like in the diagnostics example.
local rendered_output = ''

-- Keep track of the previous state to know when to redraw.
local was_working = false

local spinner_chars = { '⠇', '⠏', '⠋', '⠙', '⠹', '⠸', '⠼', '⠴' }
local spinner_index = 1

---
-- Checks if any LSP client is busy.
-- @return boolean: true if an LSP is working, false otherwise.
--
local function is_lsp_working()
  if not vim.lsp or not vim.lsp.get_active_clients or not vim.lsp.get_progress then
    return false
  end

  for _, client in ipairs(vim.lsp.get_active_clients()) do
    local progress, _ = vim.lsp.get_progress(client.id)
    if progress and next(progress) ~= nil then
      return true -- Found a working client
    end
  end

  return false
end

---
-- The setup function. It will now take `opts` from the render call
-- to ensure it has the necessary info for formatting.
--
local function init(opts)
  if initialized then
    return
  end
  initialized = true

  slimline = require('slimline')
  local timer = vim.loop.new_timer()

  -- This is the core logic, now modeled after `track_diagnostics`.
  local timer_callback = function()
    local is_working = is_lsp_working()

    if is_working then
      -- Advance the spinner
      spinner_index = (spinner_index % #spinner_chars) + 1
      local spinner_char = spinner_chars[spinner_index]
      -- Format the output using slimline's helpers, just like render would.
      rendered_output = slimline.highlights.hl_component(
        { primary = '', secondary = spinner_char },
        opts.hls,
        opts.sep,
        opts.direction,
        opts.active
      )
    else
      -- If not working, the output is empty.
      rendered_output = ''
    end

    -- THE CRUCIAL PART: When do we redraw?
    -- 1. If the state changed (e.g., from working to idle, or idle to working).
    -- 2. OR if it is currently working (to animate the spinner).
    if was_working ~= is_working or is_working then
      vim.cmd.redrawstatus()
    end

    -- Update the state for the next check.
    was_working = is_working
  end

  -- Start the timer with a small delay to let Neovim initialize.
  timer:start(200, 100, vim.schedule_wrap(timer_callback))
end

---@param opts render.options
---@return string
function C.render(opts)
  -- The init function needs the `opts` to be able to format correctly.
  -- Since opts can change (e.g., in active vs inactive windows),
  -- we call it here, but the timer is only created once.
  -- This is slightly different from the diagnostics component but necessary
  -- for our timer to have the correct formatting info.
  init(opts)

  -- The render function is now very simple: just return the pre-calculated string.
  return rendered_output
end

return C
