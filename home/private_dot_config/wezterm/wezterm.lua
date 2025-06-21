local wezterm = require("wezterm")

return {
	default_prog = { "zsh", "--login" },
	font = wezterm.font_with_fallback({ "Maple Mono NF CN", "MiSans L3" }),
	font_size = 14.0,
	warn_about_missing_glyphs = false,

	freetype_load_target = "Normal", ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
	freetype_render_target = "Normal", ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'

	color_scheme = "Catppuccin",

	colors = {
		indexed = { [16] = "#F8BD96", [17] = "#F5E0DC" },
		split = "#161320",
		visual_bell = "#302D41",
	},
	window_padding = {
		left = 5,
		right = 5,
		top = 5,
		bottom = 5,
	},

	window_background_opacity = 0.72,
	window_decorations = "RESIZE",
	enable_tab_bar = false,
	scrollback_lines = 5000,
	enable_scroll_bar = false,
	check_for_updates = false,
	max_fps = 120,
}
