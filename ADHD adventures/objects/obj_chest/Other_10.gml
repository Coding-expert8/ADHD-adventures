// Drawn by obj_world in Y order (obj_chest is a par_ysort child).
// Nothing until it is found; then it pops up out of the ground with a small bounce and the lid opens.
if (!opened) exit;
var _s = 1;
if (anim >= 0 and anim < 12)
{
	var _t = anim / 12;
	_s = (_t < 0.7) ? (_t / 0.7) * 1.15 : 1.15 - 0.15 * ((_t - 0.7) / 0.3);
}
draw_sprite_ext(sprite_index, image_index, x, y, _s, _s, 0, c_white, 1);

// a white flash as it appears
if (anim >= 0 and anim < 10)
{
	gpu_set_blendmode(bm_add);
	draw_sprite_ext(sprite_index, image_index, x, y, _s, _s, 0, c_white, 1 - anim / 10);
	gpu_set_blendmode(bm_normal);
}
