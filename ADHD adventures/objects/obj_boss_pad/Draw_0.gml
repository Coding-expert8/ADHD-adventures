// the pad: a faint ring until all six are lit, then the ground glows
var _ready = (lit >= array_length(global.beaten_flags));
var _pulse = 0.5 + 0.5 * sin(current_time / 300);
var _gold = make_color_rgb(255, 215, 90);

if (_ready)
{
	draw_set_colour(_gold);
	draw_set_alpha(0.25 + 0.15 * _pulse);
	draw_ellipse(x - radius_x * 1.3, y - radius_y * 1.3, x + radius_x * 1.3, y + radius_y * 1.3, false);
	draw_set_alpha(0.55 + 0.25 * _pulse);
	draw_ellipse(x - radius_x, y - radius_y, x + radius_x, y + radius_y, false);
}
draw_set_alpha(_ready ? 1 : 0.35);
draw_set_colour(_ready ? c_white : _gold);
draw_ellipse(x - radius_x, y - radius_y, x + radius_x, y + radius_y, true);
draw_set_alpha(1);
draw_set_colour(c_white);
