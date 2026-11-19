// PAUSE button and the pause board it opens, with four tabs:
// HOW TO PLAY, TELEPORT (minimap), STATS (this playthrough + DELETE SAVE), SETTINGS (volumes, fullscreen).
//
// The board is laid out in "board space": a MENU_BOARD_HEIGHT (480) px tall screen, scaled up to
// the real GUI by menu_board_scale(). Draw GUI and Left Pressed both get every position from the
// functions below, so what is drawn and what is clicked always line up.

help_open = false;

active_tab = 1;
help_page = 1;
help_pages = 2;

confirm_delete = false; // STATS: "Delete save?" question showing
dragging = "";          // SETTINGS: global.settings key of the slider being dragged ("" = none)

board_w = 600;
board_h = 320;

// Tabs are as wide as their label (+ padding), centred in the row left of the close button,
// which sits at the right end of the tab row.
tab_names = ["HOW TO PLAY", "TELEPORT", "STATS", "SETTINGS"];
tab_count = array_length(tab_names);
tab_gap = 6;
tab_pad = 28;
tab_row_x1 = 16;            // tab row, from the board's left edge...
tab_row_x2 = board_w - 50;  // ...to just before the close button
tab_x = [];
tab_w = [];
draw_set_font(fnt_default); // string_width measures with the font the tabs are drawn in
var _total = tab_gap * (tab_count - 1);
for (var _i = 0; _i < tab_count; _i++)
{
	tab_w[_i] = string_width(tab_names[_i]) + tab_pad;
	_total += tab_w[_i];
}
// too wide for the row (bigger font): shrink every tab by the same amount (labels shrink to fit)
var _gaps = tab_gap * (tab_count - 1);
var _avail = tab_row_x2 - tab_row_x1;
if (_total > _avail)
{
	var _k = (_avail - _gaps) / (_total - _gaps);
	for (var _i = 0; _i < tab_count; _i++) tab_w[_i] *= _k;
	_total = _avail;
}
var _x = tab_row_x1 + (_avail - _total) / 2;
for (var _j = 0; _j < tab_count; _j++)
{
	tab_x[_j] = _x;
	_x += tab_w[_j] + tab_gap;
}

// SETTINGS sliders: global.settings key and label
settings_sliders = [
	{ key: "master", label: "Master volume" },
	{ key: "music",  label: "Music" },
	{ key: "sfx",    label: "Sound effects" },
];

// colours
col_board     = make_color_rgb(112, 72, 42);
col_panel     = make_color_rgb(137, 91, 53);
col_tab       = make_color_rgb(85, 53, 32);
col_tab_hover = make_color_rgb(105, 67, 38);
col_gold      = make_color_rgb(220, 180, 115);
col_title     = make_color_rgb(255, 225, 165);
col_btn       = make_color_rgb(75, 55, 35);
col_btn_hover = make_color_rgb(98, 72, 46);
col_btn_on    = make_color_rgb(190, 135, 70);
col_red       = make_color_rgb(120, 35, 30);
col_red_hover = make_color_rgb(155, 48, 40);
col_track     = make_color_rgb(70, 45, 26);
col_green     = make_color_rgb(120, 200, 110);
col_dim       = make_color_rgb(200, 170, 135);

// ---- layout (all in board space) ----

/// Board position and the mouse, for this frame.
layout = function() {
	var _s = menu_board_scale();
	var _gw = display_get_gui_width() / _s;
	var _gh = display_get_gui_height() / _s;
	var _left = floor((_gw - board_w) / 2);
	var _top = floor((_gh - board_h) / 2);
	return {
		s: _s, gw: _gw, gh: _gh,
		left: _left, top: _top, right: _left + board_w, bottom: _top + board_h,
		cx: _left + board_w / 2,
		mx: device_mouse_x_to_gui(0) / _s,
		my: device_mouse_y_to_gui(0) / _s,
	};
}

// rectangles are [x1, y1, x2, y2]
tab_rect = function(_L, _i) {
	var _x = _L.left + tab_x[_i];
	return [_x, _L.top - 27, _x + tab_w[_i], _L.top + 8];
}
close_rect   = function(_L) { return [_L.right - 40, _L.top - 27, _L.right - 10, _L.top - 1]; } // end of the tab row
page_prev    = function(_L) { return [_L.cx - 140, _L.top + 262, _L.cx - 100, _L.top + 290]; }
page_next    = function(_L) { return [_L.cx + 100, _L.top + 262, _L.cx + 140, _L.top + 290]; }
delete_rect  = function(_L) { return [_L.cx - 90, _L.top + 238, _L.cx + 90, _L.top + 270]; }
confirm_box  = function(_L) { return [_L.cx - 200, _L.top + 88, _L.cx + 200, _L.top + 236]; }
confirm_yes  = function(_L) { return [_L.cx - 150, _L.top + 188, _L.cx - 10, _L.top + 220]; }
confirm_no   = function(_L) { return [_L.cx + 10, _L.top + 188, _L.cx + 150, _L.top + 220]; }
slider_y     = function(_L, _i) { return _L.top + 62 + _i * 46; }
slider_x1    = function(_L) { return _L.left + 215; }
slider_x2    = function(_L) { return _L.left + 475; }
slider_hit   = function(_L, _i) {
	var _y = slider_y(_L, _i);
	return [slider_x1(_L) - 12, _y - 14, slider_x2(_L) + 12, _y + 14];
}
display_y    = function(_L) { return _L.top + 200; }
// the two display buttons share the sliders' width, so everything lines up in one column
windowed_rect   = function(_L) { var _y = display_y(_L); return [slider_x1(_L), _y - 15, slider_x1(_L) + 122, _y + 15]; }
fullscreen_rect = function(_L) { var _y = display_y(_L); return [slider_x2(_L) - 122, _y - 15, slider_x2(_L), _y + 15]; }
// TELEPORT minimap: spr_teleport_map (240 x 158) drawn map_scale times its size.
// Its frame is centred; the image itself sits 27 px (scaled) left of the frame.
map_scale = 1.35;
map_w = TELEPORT_MAP_W * map_scale;
map_h = TELEPORT_MAP_H * map_scale;
map_x = function(_L) { return _L.cx - map_w / 2; }   // frame
map_y = function(_L) { return _L.top + 28; }
map_image_x = function(_L) { return map_x(_L) - 27 * map_scale; }

in_rect = function(_mx, _my, _r) {
	return point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3]);
}

/// Slider value (0-1) for a board-space mouse x.
slider_value = function(_L, _mx) {
	return clamp((_mx - slider_x1(_L)) / (slider_x2(_L) - slider_x1(_L)), 0, 1);
}

// ---- drawing helpers ----

/// Rounded button with a centred label; lighter while the mouse is over it.
ui_button = function(_L, _r, _label, _col, _col_hover) {
	draw_set_color(in_rect(_L.mx, _L.my, _r) ? _col_hover : _col);
	draw_roundrect(_r[0], _r[1], _r[2], _r[3], false);
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	ui_text_fit((_r[0] + _r[2]) / 2, (_r[1] + _r[3]) / 2, _label, _r[2] - _r[0] - 10);
}

/// Text shrunk (never stretched) to fit max_w, using the current alignment.
ui_text_fit = function(_x, _y, _str, _max_w) {
	var _sc = min(1, _max_w / max(1, string_width(_str)));
	draw_text_transformed(_x, _y, _str, _sc, _sc, 0);
}

/// "Label ........ value" row: label left-aligned at x1, value right-aligned at x2.
ui_stat_row = function(_x1, _x2, _y, _label, _value) {
	draw_set_valign(fa_middle);
	draw_set_halign(fa_left);
	draw_set_color(col_title);
	draw_text(_x1, _y, _label);
	var _label_w = string_width(_label) + 12;
	draw_set_halign(fa_right);
	draw_set_color(c_white);
	ui_text_fit(_x2, _y, _value, _x2 - _x1 - _label_w);
}
