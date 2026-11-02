// The patch of dark, laid over the day/night tint but under the lamps (see the
// depth in Create).
if (shade_cover <= 0 or !shader_is_compiled(shd_shade)) exit;

// Shade is the absence of direct light, so it goes as the light goes: a cliff
// casts nothing at midnight, because there is no sun left for it to stand in the
// way of. Without this the shaded patches would be the one part of the map that
// ignored the time of day.
var _cover = shade_cover * (1 - daylight_darkness() * SHADE_NIGHT_FADE);
if (_cover <= 0) exit;

// The marked-out region, straight off the scaled box.
var _x = bbox_left;
var _y = bbox_top;
var _w = bbox_right  - bbox_left + 1;
var _h = bbox_bottom - bbox_top  + 1;

var _v = world_view_rect();
if (_x > _v[0] + _v[2] or _x + _w < _v[0]) exit;    // off the side of the view
if (_y > _v[1] + _v[3] or _y + _h < _v[1]) exit;    // above or below it

shader_set(shd_shade);
shader_set_uniform_f(u_rect, _x, _y, _w, _h);
shader_set_uniform_f(u_colour,
    colour_get_red(shade_colour)   / 255,
    colour_get_green(shade_colour) / 255,
    colour_get_blue(shade_colour)  / 255,
    _cover);
// The feather is a number of pixels, so it has to be handed over as a fraction of
// this region's own size. Capped at half: a region thinner than two feathers
// never reaches full depth in the middle, which is right -- a narrow strip of
// shade is a soft one all the way across.
shader_set_uniform_f(u_feather, min(shade_feather / _w, 0.5), min(shade_feather / _h, 0.5));
draw_rectangle(_x, _y, _x + _w, _y + _h, false);
shader_reset();
