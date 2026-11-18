// SETTINGS tab: drag a volume slider while the mouse button is held (grabbed in Left Pressed)
if (dragging == "") exit;

if (!help_open or active_tab != 4)
{
	dragging = "";
	exit;
}

var L = layout();

if (mouse_check_button(mb_left))
{
	var v = slider_value(L, L.mx);
	if (v != global.settings[$ dragging])
	{
		global.settings[$ dragging] = v;
		settings_apply_audio();
	}
}
else
{
	// let go: keep the setting, and click so the new volume can be heard
	dragging = "";
	settings_save();
	play_select();
}
