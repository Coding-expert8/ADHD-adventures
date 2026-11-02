// The pool of light the lamp throws at night, added on top of the darkened scene.
//
// Draw End, not the Y-sorted draw obj_world runs, because the darkness is drawn in Draw End
// too. obj_daylight_control sits at depth 16000 so its quad goes down first, and this
// instance is on the Instances layer at depth 300, so it comes later in the same
// depth-ordered queue and lands on top of the dark. Drawing the glow in the ordinary Draw
// event would put it under the tint, where the very night it exists to light would dim it.
//
// (If a Create event is ever added here, call event_inherited() first -- obj_prop's Create
// is what stops the sprite animating.)
var _dark = daylight_darkness();
if (_dark <= 0) exit;                               // broad daylight, or the tint is switched off
if (!instance_exists(obj_daylight_control)) exit;   // nothing darkened this room, so nothing to light

// The bulb, not the instance's own position: these sprites are anchored at their top-left
// corner and stand up to 192px tall, so the light source is most of a sprite above the point
// the prop was placed at. Scale is signed so flipped props still land in the right place;
// the radii take its size only.
var _sx = image_xscale, _sy = image_yscale;
var _lx = x - sprite_get_xoffset(sprite_index) * _sx + sprite_get_width(sprite_index)  * _sx * 0.5;
var _ly = y - sprite_get_yoffset(sprite_index) * _sy + sprite_get_height(sprite_index) * _sy * LAMP_BULB_FRACTION;
var _r  = abs(_sy);

// bm_add adds light to what is already on screen instead of painting over it, so the ground
// keeps its own colours and simply gets brighter. The outer colour of each circle is black,
// which under bm_add adds nothing -- that is what fades the pool out at its edge instead of
// ending it on a hard rim.
gpu_set_blendmode(bm_add);
draw_set_alpha(LAMP_GLOW_ALPHA * _dark);
draw_circle_colour(_lx, _ly, LAMP_GLOW_RADIUS * _r, LAMP_GLOW_COLOUR, c_black, false);
draw_set_alpha(LAMP_CORE_ALPHA * _dark);
draw_circle_colour(_lx, _ly, LAMP_CORE_RADIUS * _r, LAMP_GLOW_COLOUR, c_black, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
