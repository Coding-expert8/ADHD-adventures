// Darken the box, softly, with nothing but a blend mode and a gradient.
//
// gpu_set_blendmode_ext(bm_zero, bm_inv_src_colour) makes every pixel drawn here
// come out as screen * (1 - what_was_drawn). So a grey multiplies the ground down
// -- it scales the light instead of taking a fixed amount off it, which keeps the
// detail in the shade rather than crushing it to black -- and pure black changes
// nothing at all. Drawing the ellipse grey in the middle and black at the rim is
// therefore all the soft edge needs: the rim multiplies by 1.
//
// One soft ellipse per instance. To follow something that is not an oval -- the
// foot of a cliff that bends -- overlap two or three. Where they overlap the
// darkening multiplies (0.8 * 0.8 = 0.64), so it deepens rather than banding, but
// it does deepen: keep each one gentle if you are going to stack them.
var _s = shade_strength * (1 - SHADE_NIGHT_FADE * daylight_darkness());
if (_s <= 0) exit;

// Shade is lit by the sky rather than the sun, so it is cooler than what is around
// it. Taking more red out than blue is what leaves it blue.
var _col = make_colour_rgb(_s * 255 * 1.00, _s * 255 * 0.92, _s * 255 * 0.78);

gpu_set_blendmode_ext(bm_zero, bm_inv_src_colour);
draw_ellipse_colour(bbox_left, bbox_top, bbox_right, bbox_bottom, _col, c_black, false);
gpu_set_blendmode(bm_normal);
