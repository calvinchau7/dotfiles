-- WezTerm: the terminal for Windows (Ghostty/kitty don't run there), but this
-- config works on macOS/Linux too. Look matches ghostty/config.ghostty.
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find('windows') ~= nil

-- same font everywhere (Windows: scoop nerd-fonts/Iosevka-NF-Mono)
config.font = wezterm.font('Iosevka Nerd Font Mono')
config.font_size = 14.0
config.color_scheme = 'GruvboxDarkHard'
config.window_padding = { left = 10, right = 10, top = 0, bottom = 0 }

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.window_close_confirmation = 'NeverPrompt'
config.audible_bell = 'Disabled'
config.scrollback_lines = 10000
config.max_fps = 120

config.keys = {
  -- free Ctrl+N/P for Neovim (Ctrl+Shift versions still work)
  { key = 'N', mods = 'CTRL', action = act.DisableDefaultAssignment },
  { key = 'P', mods = 'CTRL', action = act.DisableDefaultAssignment },
  { key = 'phys:N', mods = 'CTRL|SHIFT', action = act.SpawnWindow },
  { key = 'phys:P', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = '\\', mods = 'ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'ALT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'w', mods = 'ALT', action = act.CloseCurrentPane { confirm = false } },
}

if is_windows then
  -- Nushell, falling back to PowerShell if it isn't installed
  local nu = wezterm.run_child_process { 'where.exe', 'nu' }
  config.default_prog = nu and { 'nu' } or { 'pwsh.exe', '-NoLogo' }

  -- Windows-style copy/paste: Ctrl+C copies if something is selected,
  -- otherwise sends a normal Ctrl+C
  table.insert(config.keys, {
    key = 'c', mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      if window:get_selection_text_for_pane(pane) ~= '' then
        window:perform_action(act.CopyTo 'Clipboard', pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
      end
    end),
  })
  table.insert(config.keys, { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' })

  wezterm.on('gui-startup', function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():set_inner_size(1920, 1080)
  end)
end

return config
