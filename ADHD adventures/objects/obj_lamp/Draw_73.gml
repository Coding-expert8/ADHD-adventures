var _dark = daylight_darkness()
if (_dark <= 0) exit
if (!instance_exists(obj_daylight_control)) exit

var _sx = image_xscale, _sy = image_yscale
var _lx = x - sprite_get_xoffset(sprite_index) * _sx + sprite_get_width(sprite_index)  * _sx * 0.5
var _ly = y - sprite_get_yoffset(sprite_index) * _sy + sprite_get_height(sprite_index) * _sy * LAMP_BULB_FRACTION
var _r  = abs(_sy)

gpu_set_blendmode(bm_add)
draw_set_alpha(LAMP_GLOW_ALPHA * _dark)
draw_circle_colour(_lx, _ly, LAMP_GLOW_RADIUS * _r, LAMP_GLOW_COLOUR, c_black, false)
draw_set_alpha(LAMP_CORE_ALPHA * _dark)
draw_circle_colour(_lx, _ly, LAMP_CORE_RADIUS * _r, LAMP_GLOW_COLOUR, c_black, false)
gpu_set_blendmode(bm_normal)
draw_set_alpha(1)
