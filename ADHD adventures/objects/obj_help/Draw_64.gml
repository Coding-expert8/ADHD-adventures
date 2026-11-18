draw_set_font(fnt_default);

var gw = display_get_gui_width();

// PAUSE button (top right, left of CREDITS, so it doesn't cover the hearts)
var button_x = gw - 260;
var button_y = 20;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(make_color_rgb(105, 67, 38));
draw_roundrect(button_x, button_y, button_x + 110, button_y + 35, false);

draw_set_color(c_white);
draw_text(button_x + 55, button_y + 17, "PAUSE");

if (help_open)
{
	// every position comes from the layout functions in Create (shared with Left Pressed)
	var L = layout();
	var left = L.left;
	var top = L.top;
	var cx = L.cx;
	matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, L.s, L.s, 1));

	// Dark overlay
	draw_set_color(make_color_rgb(10, 25, 18));
	draw_set_alpha(0.75);
	draw_rectangle(0, 0, L.gw, L.gh, false);
	draw_set_alpha(1);

	// Tabs (drawn first, so the board covers their lower edge; the active one joins the panel)
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	for (var t = 0; t < tab_count; t++)
	{
		var r = tab_rect(L, t);
		var on = (active_tab == t + 1);
		draw_set_color(on ? col_panel : (in_rect(L.mx, L.my, r) ? col_tab_hover : col_tab));
		draw_roundrect(r[0], r[1], r[2], top + 13, false);
		draw_set_color(on ? c_white : col_dim);
		ui_text_fit((r[0] + r[2]) / 2, top - 13, tab_names[t], r[2] - r[0] - 14);
	}

	// Wooden board
	draw_set_color(col_board);
	draw_roundrect(left, top, L.right, L.bottom, false);

	// Inner panel
	draw_set_color(col_panel);
	draw_roundrect(left + 10, top + 10, L.right - 10, L.bottom - 10, false);

	// the active tab runs on into the panel
	var ar = tab_rect(L, active_tab - 1);
	draw_rectangle(ar[0], top - 2, ar[2], top + 13, false);

	// Border
	draw_set_color(col_gold);
	draw_rectangle(left + 18, top + 18, L.right - 18, L.bottom - 18, true);

	// TAB 1: HOW TO PLAY
	if (active_tab == 1)
	{
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_color(col_title);

		if (help_page == 1)
		{
			draw_text(left + 40, top + 50, "MOVEMENT & CONTROLS");

			draw_set_color(c_white);
			draw_text(left + 40, top + 90,  "ARROW KEYS / WASD - Move");
			draw_text(left + 40, top + 120, "SHIFT - Sprint");
			draw_text(left + 40, top + 150, "Q - Talk to NPCs");
			draw_text(left + 40, top + 180, "F - Fullscreen on / off");
			draw_text(left + 40, top + 210, "F5 - Save the game");
		}
		else if (help_page == 2)
		{
			draw_text(left + 40, top + 50, "GAME PROGRESSION");

			draw_set_color(c_white);
			draw_set_valign(fa_top);
			draw_text_ext(left + 40, top + 80,
				"Collect keys throughout your adventure to unlock the final boss.\n\n"
				+ "Lose all your hearts and your adventure starts again from the beginning.",
				22, board_w - 80);
		}

		// Page arrows
		ui_button(L, page_prev(L), "<", col_btn, col_btn_hover);
		ui_button(L, page_next(L), ">", col_btn, col_btn_hover);

		var pr = page_prev(L);
		draw_set_color(col_title);
		draw_text(cx, (pr[1] + pr[3]) / 2, string(help_page) + " / " + string(help_pages));
	}

	// TAB 2: TELEPORTATION MAP
	else if (active_tab == 2)
	{
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);

		// Fixed map frame position; the image itself sits 27 px (scaled) left of the frame
		var mapx = map_x(L);
		var mapy = map_y(L);
		var image_x = map_image_x(L);
		var ms = map_scale;
		draw_sprite_ext(spr_teleport_map, 0, image_x, mapy, ms, ms, 0, c_white, 1);

		draw_set_color(col_gold);
		draw_rectangle(mapx - 1, mapy - 1, mapx + map_w, mapy + map_h, true);

		// Teleport points: a star once the area has been visited, a lock until then
		var hover = teleport_point_at(L.mx, L.my, image_x, mapy, ms);

		with (obj_teleport_point)
		{
			var px = teleport_map_x(x, image_x, ms);
			var py = teleport_map_y(y, mapy, ms);
			var discovered = area_is_discovered(area_name);

			if (id == hover)
			{
				draw_set_color(c_white);
				draw_set_alpha(0.5);
				draw_circle(px, py, 9 * ms, false);
				draw_set_alpha(1);
			}
			draw_teleport_icon(px, py, ((id == hover) ? 8 : 7) * ms, discovered);
		}

		// Hint line: what the hovered point is
		var hint = "Click a star to teleport  -  visit an area to unlock it";
		if (hover != noone)
		{
			hint = area_is_discovered(hover.area_name)
				? "Teleport to " + hover.label
				: "Locked - explore to discover it";
		}

		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(c_white);
		ui_text_fit(cx, top + 262, hint, board_w - 60);
	}

	// TAB 3: STATS of this playthrough
	else if (active_tab == 3)
	{
		// left column: the player
		var lx1 = left + 40;
		var lx2 = cx - 18;

		var areas_total = instance_number(obj_teleport_point);
		var areas_found = 0;
		with (obj_teleport_point) if (area_is_discovered(area_name)) areas_found += 1;

		var keys_text = string(global.key_count);
		if (global.keys_pending > 0) keys_text += "  (+" + string(global.keys_pending) + " to collect)";

		ui_stat_row(lx1, lx2, top + 50,  "Name",      global.username == "" ? "-" : global.username);
		ui_stat_row(lx1, lx2, top + 76,  "Character", global.character + " / 6");
		ui_stat_row(lx1, lx2, top + 102, "Hearts",    string(max(0, global.hearts) / 2) + " / " + string(HEARTS_MAX / 2));
		ui_stat_row(lx1, lx2, top + 128, "Coins",     string(global.coin));
		ui_stat_row(lx1, lx2, top + 154, "Keys",      keys_text);
		ui_stat_row(lx1, lx2, top + 180, "Areas found", string(areas_found) + " / " + string(areas_total));
		ui_stat_row(lx1, lx2, top + 206, "Play time", format_play_time(global.play_time));

		// divider between the columns
		draw_set_color(col_gold);
		draw_line(cx, top + 38, cx, top + 214);

		// right column: minigames
		var rx1 = cx + 20;
		var rx2 = L.right - 40;
		var beaten = 0;
		for (var b = 0; b < array_length(global.beaten_flags); b++)
		{
			if (variable_global_get(global.beaten_flags[b])) beaten += 1;
		}
		ui_stat_row(rx1, rx2, top + 50, "Minigames", string(beaten) + " / " + string(array_length(global.beaten_flags)));

		for (var g = 0; g < array_length(global.beaten_flags); g++)
		{
			var gy = top + 80 + g * 24;
			var done = variable_global_get(global.beaten_flags[g]);

			draw_set_color(done ? col_green : col_track);
			draw_circle(rx1 + 6, gy, 5, false);

			draw_set_valign(fa_middle);
			draw_set_halign(fa_left);
			draw_set_color(c_white);
			draw_text(rx1 + 20, gy, global.beaten_names[g]);

			draw_set_halign(fa_right);
			draw_set_color(done ? col_green : col_dim);
			draw_text(rx2, gy, done ? "Beaten" : "Not yet");
		}

		draw_set_color(col_gold);
		draw_line(left + 40, top + 228, L.right - 40, top + 228);

		ui_button(L, delete_rect(L), "DELETE SAVE", col_red, col_red_hover);

		// "Are you sure?" on top of the stats
		if (confirm_delete)
		{
			draw_set_color(c_black);
			draw_set_alpha(0.55);
			draw_roundrect(left + 10, top + 10, L.right - 10, L.bottom - 10, false);
			draw_set_alpha(1);

			var cb = confirm_box(L);
			draw_set_color(col_board);
			draw_roundrect(cb[0], cb[1], cb[2], cb[3], false);
			draw_set_color(col_gold);
			draw_roundrect(cb[0], cb[1], cb[2], cb[3], true);

			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_color(col_title);
			draw_text(cx, cb[1] + 26, "DELETE YOUR SAVE?");
			draw_set_color(c_white);
			ui_text_fit(cx, cb[1] + 58, "All progress is lost. Settings are kept.", cb[2] - cb[0] - 30);
			draw_text(cx, cb[1] + 84, "This can't be undone.");

			ui_button(L, confirm_yes(L), "DELETE", col_red, col_red_hover);
			ui_button(L, confirm_no(L), "CANCEL", col_btn, col_btn_hover);
		}
	}

	// TAB 4: SETTINGS
	else if (active_tab == 4)
	{
		var sx1 = slider_x1(L);
		var sx2 = slider_x2(L);

		for (var k = 0; k < array_length(settings_sliders); k++)
		{
			var sl = settings_sliders[k];
			var sy = slider_y(L, k);
			var v = global.settings[$ sl.key];
			var kx = sx1 + v * (sx2 - sx1);
			var hot = (dragging == sl.key) or in_rect(L.mx, L.my, slider_hit(L, k));

			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			draw_set_color(col_title);
			draw_text(left + 45, sy, sl.label);

			// track, filled part, knob
			draw_set_color(col_track);
			draw_roundrect(sx1, sy - 4, sx2, sy + 4, false);
			draw_set_color(col_gold);
			if (kx > sx1 + 1) draw_roundrect(sx1, sy - 4, kx, sy + 4, false);
			draw_set_color(hot ? c_white : col_title);
			draw_circle(kx, sy, hot ? 10 : 9, false);
			draw_set_color(col_board);
			draw_circle(kx, sy, hot ? 10 : 9, true);

			draw_set_halign(fa_right);
			draw_set_color(c_white);
			draw_text(L.right - 45, sy, string(round(v * 100)) + "%");
		}

		// Display: windowed / fullscreen
		var dy = display_y(L);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_color(col_title);
		draw_text(left + 45, dy, "Display");

		var fs = global.settings.fullscreen;
		ui_button(L, windowed_rect(L), "WINDOWED", fs ? col_btn : col_btn_on, fs ? col_btn_hover : col_btn_on);
		ui_button(L, fullscreen_rect(L), "FULLSCREEN", fs ? col_btn_on : col_btn, fs ? col_btn_on : col_btn_hover);

		draw_set_color(col_gold);
		draw_line(left + 40, top + 236, L.right - 40, top + 236);

		draw_set_halign(fa_center);
		draw_set_color(col_dim);
		ui_text_fit(cx, top + 262, "Settings save automatically.  F toggles fullscreen.", board_w - 60);
	}

	// Close button (last, on top of everything on the board)
	ui_button(L, close_rect(L), "X", col_red, col_red_hover);
}

// Reset drawing settings
matrix_set(matrix_world, matrix_build_identity());
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
