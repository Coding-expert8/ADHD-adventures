var _pulse = 0.5 + 0.5 * sin(current_time / 250);
var _rx = radius_x * grow;
var _ry = radius_y * grow;
var _h  = glow_height * grow * (0.9 + 0.1 * _pulse);
var _a  = 0.5 + 0.15 * _pulse;

// light rising from the circle: brightest in the middle at the bottom, fading out upwards
// and towards the sides
draw_primitive_begin(pr_trianglestrip);
draw_vertex_colour(x - _rx, y,      colour, _a * 0.25);
draw_vertex_colour(x - _rx, y - _h, colour, 0);
draw_vertex_colour(x,       y,      colour, _a);
draw_vertex_colour(x,       y - _h, colour, 0);
draw_vertex_colour(x + _rx, y,      colour, _a * 0.25);
draw_vertex_colour(x + _rx, y - _h, colour, 0);
draw_primitive_end();

// the circle on the ground
draw_set_colour(colour);
draw_set_alpha(0.55 + 0.2 * _pulse);
draw_ellipse(x - _rx, y - _ry, x + _rx, y + _ry, false);
draw_set_alpha(1);
draw_set_colour(c_white);
draw_ellipse(x - _rx, y - _ry, x + _rx, y + _ry, true);
