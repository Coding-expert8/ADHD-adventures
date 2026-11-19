// Drawn in Draw End, above the props, like the NPCs' "Q" hint.

if (!opened)
{
	// not found yet: a soft glow on the ground with three twinkles taking turns
	var _gy = y - 10;
	gpu_set_blendmode(bm_add);
	draw_set_alpha(0.18 + 0.08 * sin(current_time / 300));
	draw_set_colour(make_colour_rgb(255, 210, 90));
	draw_ellipse(x - 18, _gy - 7, x + 18, _gy + 7, false);
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
	var _pts = [[-10, -6], [9, -16], [2, 4]];
	for (var _i = 0; _i < 3; _i++)
	{
		var _ph = (current_time / 900 + _i / 3) mod 1;        // 0..1, each twinkle on its own beat
		var _k  = sin(_ph * pi);                             // grows then shrinks
		sparkle(x + _pts[_i][0], _gy + _pts[_i][1] - _ph * 6, 7 * _k, 0.95 * _k);
	}

	if (near and !instance_exists(global.dialogue_npc))
	{
		if (variable_global_exists("dialogue_font")) draw_set_font(global.dialogue_font);
		draw_set_colour(c_white);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_text_transformed(x, y - 34 + sin(current_time / 200) * 2, "Q", 0.8, 0.8, 0);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(-1);
	}
	exit;
}

// just opened: sparkles burst out and "+50 coins" floats up and fades
if (anim >= open_at and anim < open_at + 120)
{
	var _t = anim - open_at;
	for (var _i = 0; _i < 6; _i++)
	{
		var _a = 90 + (_i - 2.5) * 28;
		var _d = 8 + _t * 0.9;
		var _k = max(0, 1 - _t / 40);
		sparkle(x + lengthdir_x(_d, _a), y - 22 + lengthdir_y(_d, _a), 6 * _k, _k);
	}
	var _fade = (_t < 80) ? 1 : 1 - (_t - 80) / 40;
	var _ty = y - 44 - min(_t, 60) * 0.5;
	if (variable_global_exists("dialogue_font")) draw_set_font(global.dialogue_font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	var _txt = "+" + string(coins);
	var _sc  = 0.6;
	var _cw  = 14;                                    // the coin icon, drawn left of the number
	var _w   = _cw + 4 + string_width(_txt) * _sc;
	var _lx  = x - _w / 2;
	draw_sprite_ext(spr_coin, 0, _lx + _cw / 2, _ty, _cw / 192, _cw / 192, 0, c_white, _fade);
	draw_set_alpha(_fade);
	draw_set_colour(c_black);
	draw_text_transformed(_lx + _cw + 5, _ty + 1, _txt, _sc, _sc, 0);    // shadow
	draw_set_colour(make_colour_rgb(255, 226, 110));
	draw_text_transformed(_lx + _cw + 4, _ty, _txt, _sc, _sc, 0);
	draw_set_alpha(1);
	draw_set_valign(fa_top);
	draw_set_font(-1);
}
