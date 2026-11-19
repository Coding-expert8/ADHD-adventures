// A hidden chest on room_map. Until it is found it is only a sparkle on the ground; standing
// next to it shows a floating "Q", and pressing Q makes the chest pop up and open, giving
// choose(10, 50, 100) coins (global.coin, saved in save.ini). Opened chests stay open.
//
// Each chest has its own chest_id, set in its Instance Creation Code, e.g. chest_id = "chest_town";
// global.chests_opened remembers which ids have been opened (see chest_opened in scr_save).
chest_id   = "";
opened     = false;
coins      = 0;
anim       = -1;        // frames since it was opened here (-1: already open when the room started)
open_at    = 16;        // the lid opens this many frames after the chest pops up
talk_range = 52;        // how close the player's feet must be to press Q
near       = false;
image_speed = 0;
image_index = 0;
// stays visible (an invisible instance runs no Draw events at all, so no sparkle); the chest
// itself is only drawn once opened, see User Event 0

/// a four-pointed twinkle
sparkle = function(_x, _y, _r, _a) {
	if (_r <= 0.5) return;
	draw_set_alpha(_a);
	draw_set_colour(make_colour_rgb(255, 236, 150));
	draw_triangle(_x - _r * 0.28, _y, _x + _r * 0.28, _y, _x, _y - _r, false);
	draw_triangle(_x - _r * 0.28, _y, _x + _r * 0.28, _y, _x, _y + _r, false);
	draw_triangle(_x, _y - _r * 0.28, _x, _y + _r * 0.28, _x - _r, _y, false);
	draw_triangle(_x, _y - _r * 0.28, _x, _y + _r * 0.28, _x + _r, _y, false);
	draw_set_colour(c_white);
	draw_circle(_x, _y, _r * 0.22, false);
	draw_set_alpha(1);
};
