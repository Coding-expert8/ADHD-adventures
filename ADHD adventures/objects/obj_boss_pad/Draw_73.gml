// Drawn in Draw End, above the player and the props.
var _n = array_length(global.beaten_flags);

// the ring of pills around the player while standing on the pad
if (show > 0 and instance_exists(obj_player))
{
	var _cx = obj_player.x;
	var _cy = obj_player.y;                    // the player's middle (sprite origin is centred)
	var _w  = 52 * icon_scale;                 // size of the pill inside spr_key
	var _h  = 37 * icon_scale;
	for (var _i = 0; _i < _n; _i++)
	{
		var _a  = 90 - _i * 360 / _n;           // first pill at the top, then clockwise
		var _px = _cx + lengthdir_x(icon_radius_x * show, _a);
		var _py = _cy + lengthdir_y(icon_radius_y * show, _a);
		if (_i < lit)
		{
			// lit: the pill sprite, smaller (its pill is centred on x 32, y 35.5 of the 64 px image)
			draw_sprite_ext(spr_key, 0, _px - 32 * icon_scale, _py - 35.5 * icon_scale, icon_scale, icon_scale, 0, c_white, show);
		}
		else
		{
			// not yet: a dark see-through pill with a white outline
			draw_set_colour(make_colour_rgb(40, 40, 40));
			draw_set_alpha(0.55 * show);
			draw_roundrect_ext(_px - _w / 2, _py - _h / 2, _px + _w / 2, _py + _h / 2, _h, _h, false);
			draw_set_colour(c_white);
			draw_set_alpha(0.9 * show);
			draw_roundrect_ext(_px - _w / 2, _py - _h / 2, _px + _w / 2, _py + _h / 2, _h, _h, true);
			draw_roundrect_ext(_px - _w / 2 + 1, _py - _h / 2 + 1, _px + _w / 2 - 1, _py + _h / 2 - 1, _h - 2, _h - 2, true); // 2 px thick
			draw_set_alpha(1);
		}
	}
}

// all six lit and standing on it: a floating Q, like the NPCs' talk hint
if (inside and lit >= _n and !instance_exists(global.dialogue_npc) and instance_exists(obj_player))
{
	if (variable_global_exists("dialogue_font")) draw_set_font(global.dialogue_font);
	draw_set_colour(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text_transformed(obj_player.x, obj_player.y - icon_radius_y - 18 + sin(current_time / 200) * 3, "Q", 0.8, 0.8, 0);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(-1);
}
