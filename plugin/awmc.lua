if vim.g.loaded_awmc == 1 then return end
vim.g.loaded_awmc = 1

local utils = require 'awmc.utils'

local log = utils.log

local throw = utils.throw

log 'starting'

--------------------------------------------------------------------------------

local system = function(cmds) return vim.system(cmds, { detach = false }) end

local _last = 0

---@param name string
---@param opts? { min?: integer, debounce?: boolean }
local play_file = function(name, opts)
  opts = opts or {}
  if opts.debounce == nil or opts.debounce then
    local min = opts.min or 50
    local now = vim.uv.now()
    if now - _last < min then return end
    _last = now
  end

  local path = utils.get_resource_path(name)
  local exepath = function(exename)
    local res = vim.fn.exepath(exename)
    return res ~= '' and res or nil
  end
  local afplay_path = exepath 'afplay'
  if afplay_path then
    system { afplay_path, path }
    return
  end
  local aplay_path = exepath 'aplay'
  if aplay_path then
    system { aplay_path, path }
    return
  end
  local mpv_path = exepath 'mpv'
  if mpv_path then
    -- still slow af
    system {
      mpv_path,
      '--no-video',
      '--no-config',
      '--no-load-scripts',
      '--really-quiet',
      path,
    }
    return
  end
  throw 'I can\'t find an audio player, tried afplay, aplay, mpv'
end

local play_break_perfect = function()
  log 'playing break perfect sound'
  play_file 'break-perfect.wav'
end

local play_tap_perfect = function()
  log 'playing tap perfect sound'
  play_file 'tap-perfect.wav'
end

local play_break_good = function()
  log 'playing break good sound'
  play_file 'tap-good.wav'
end

local play_track_start = function()
  log 'playing track start sound'
  play_file 'track-start.wav'
end

local play_credit = function()
  log 'playing credit sound'
  play_file 'credit.wav'
end

local play_switch_category = function()
  log 'playing switch category sound'
  play_file 'switch-category.wav'
end

local play_switch_track = function()
  log 'playing switch track sound'
  play_file 'switch-track.wav'
end

local play_cancel = function()
  log 'playing cancel sound'
  play_file 'cancel.wav'
end

local is_cr = function(key) return key == '<CR>' end

local is_deleting_char = function(key)
  return key == '<BS>' or key == '<Del>' or key == '<C-W>' or key == '<C-H>'
end

local is_normal_char = function(key) return key ~= '<Esc>' and key ~= '<C-C>' end

local on_cr = function()
  play_break_perfect()
  vim.notify 'CRITICAL PERFECT'
end

local on_normal_char = function()
  play_tap_perfect()
  vim.notify 'PERFECT'
end

local on_deleting_char = function()
  play_break_good()
  vim.notify 'GOOD'
end

local on_enter_insert = function() play_track_start() end

local on_init = function()
  play_credit()
  vim.notify_once '要开始了哟！'
end

local on_small_motion = function() play_switch_track() end

local on_big_motion = function() play_switch_category() end

local on_leave_insert = function() play_cancel() end

local is_small_motion = function(key)
  return vim.tbl_contains({
    '$',
    '0',
    '<C-E>',
    '<C-Y>',
    '<Down>',
    '<Left>',
    '<Right>',
    '<Up>',
    '^',
    'B',
    'b',
    'E',
    'e',
    'g',
    'H',
    'h',
    'j',
    'k',
    'L',
    'l',
    'M',
    'N',
    'n',
    'W',
    'w',
    '|',
  }, key) or key:match '^<Scroll'
end

local is_big_motion = function(key)
  return vim.tbl_contains({
    '(',
    ')',
    '<C-B>',
    '<C-D>',
    '<C-F>',
    '<C-U>',
    'G',
    '{',
    '}',
  }, key)
end

local main = function()
  on_init()

  local augroup = vim.api.nvim_create_augroup('awmc', {})
  local ns = vim.api.nvim_create_namespace 'awmc-on-key'

  vim.api.nvim_create_autocmd('InsertEnter', {
    group = augroup,
    callback = function() on_enter_insert() end,
  })

  vim.api.nvim_create_autocmd('InsertLeave', {
    group = augroup,
    callback = function() on_leave_insert() end,
  })

  vim.on_key(function(keycode, _)
    local key = vim.fn.keytrans(keycode)
    local mode = vim.api.nvim_get_mode().mode
    log(('pressed key %q %q, mode %s'):format(keycode, key, mode))
    if mode == 'n' or mode == 'v' or mode == 'V' then
      if is_small_motion(key) then
        on_small_motion()
      elseif is_big_motion(key) then
        on_big_motion()
      end
    elseif mode:match '^i' then
      if is_cr(key) then
        on_cr()
      elseif is_deleting_char(key) then
        on_deleting_char()
      elseif is_normal_char(key) then
        on_normal_char()
      end
    end
  end, ns)
end

main()
-- stylua: ignore





































































































--[[
 Hey 27,

 I don't know if you expected to find this here,
 but I want you to know how grateful I am to have you in my life.

 The plugin is a silly one. My appreciation for you isn't.

 Thank you for being you.
 Happy birthday.

 >>=

 - f
]]
