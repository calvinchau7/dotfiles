-- Rex configuration, migrated from Ghostty (~/dotfiles/ghostty/.config/ghostty/config.ghostty).
-- Ghostty binds no keys, so Rex's defaults stay in effect.
-- cmd+k keeps Rex's session picker (session.switch), by choice.

-- Move focus between panes.
rex.bind("shift+cmd+j", "pane.focus_next")
rex.bind("shift+cmd+k", "pane.focus_previous")
