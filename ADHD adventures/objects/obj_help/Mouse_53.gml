// Global Left Pressed: the PAUSE button, and everything on the pause board.
// Positions come from the layout functions in Create, the same ones Draw GUI uses.

// PAUSE button (top right, left of CREDITS)
if (!help_open)
{
	var _gw = display_get_gui_width();
	var _mx = device_mouse_x_to_gui(0);
	var _my = device_mouse_y_to_gui(0);
	var button_x = _gw - 260;
	var button_y = 20;

	if (!pause_menu_open() and
		_mx >= button_x and _mx <= button_x + 110 and
		_my >= button_y and _my <= button_y + 35)
	{
		play_select();
		help_open = true;
		active_tab = 1;
		help_page = 1;
		confirm_delete = false;
		dragging = "";
	}
	exit;
}

var L = layout();
var mx = L.mx;
var my = L.my;

// Close button
if (in_rect(mx, my, close_rect(L)))
{
	play_select();
	help_open = false;
	confirm_delete = false;
	dragging = "";
	exit;
}

// "Delete your save?" is showing: only its two buttons answer
if (confirm_delete)
{
	if (in_rect(mx, my, confirm_yes(L)))
	{
		play_select();
		confirm_delete = false;
		help_open = false;
		reset_save();       // wipes save.ini and every progress global (settings are kept)
		restart_on_map();   // new game, in the village
	}
	else if (in_rect(mx, my, confirm_no(L)))
	{
		play_select();
		confirm_delete = false;
	}
	exit;
}

// Tabs
for (var i = 0; i < tab_count; i++)
{
	if (in_rect(mx, my, tab_rect(L, i)))
	{
		if (active_tab != i + 1) play_select();
		active_tab = i + 1;
		exit;
	}
}

switch (active_tab)
{
	// HOW TO PLAY: page arrows
	case 1:
		if (in_rect(mx, my, page_prev(L)))
		{
			play_select();
			help_page = max(1, help_page - 1);
		}
		else if (in_rect(mx, my, page_next(L)))
		{
			play_select();
			help_page = min(help_pages, help_page + 1);
		}
		break;

	// TELEPORT: only discovered teleport points can be clicked
	case 2:
		var tp = teleport_point_at(mx, my, map_image_x(L), map_y(L), map_scale);

		if (tp != noone and area_is_discovered(tp.area_name) and instance_exists(obj_player))
		{
			play_select();
			obj_player.x = tp.x;
			obj_player.y = tp.y;
			help_open = false;
		}
		break;

	// STATS: delete save asks first
	case 3:
		if (in_rect(mx, my, delete_rect(L)))
		{
			play_select();
			confirm_delete = true;
		}
		break;

	// SETTINGS: grab a slider (Step drags it) or pick windowed / fullscreen
	case 4:
		for (var j = 0; j < array_length(settings_sliders); j++)
		{
			if (in_rect(mx, my, slider_hit(L, j)))
			{
				var key = settings_sliders[j].key;
				dragging = key;
				global.settings[$ key] = slider_value(L, mx);
				settings_apply_audio();
				exit;
			}
		}
		if (in_rect(mx, my, windowed_rect(L)) and global.settings.fullscreen)
		{
			play_select();
			settings_set_fullscreen(false);
		}
		else if (in_rect(mx, my, fullscreen_rect(L)) and !global.settings.fullscreen)
		{
			play_select();
			settings_set_fullscreen(true);
		}
		break;
}
