var _on = area_is_discovered(area_name);
var _t = current_time / 1000;

// glowing pad on the ground
var _pulse = 0.5 + 0.5 * sin(_t * 3);
draw_set_alpha(0.35 + 0.25 * _pulse);
draw_set_color(_on ? make_color_rgb(255, 215, 90) : make_color_rgb(120, 120, 135));
draw_ellipse(x - 20, y - 8, x + 20, y + 8, false);
draw_set_alpha(1);
draw_set_color(_on ? make_color_rgb(200, 140, 30) : make_color_rgb(70, 70, 78));
draw_ellipse(x - 20, y - 8, x + 20, y + 8, true);

// star or lock floating above it
draw_teleport_icon(x, y - 30 + sin(_t * 2) * 3, 10, _on);

draw_set_color(c_white);
