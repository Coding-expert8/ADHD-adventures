if (global.dialogue_npc != id) exit;

// lay out in 720p units and scale to whatever the GUI size is (SDF text stays sharp)
var _s = display_get_gui_height() / 720;
var _w = display_get_gui_width() / _s;
matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _s, _s, 1));

var _bw = min(sprite_get_width(spr_dialogue_box), _w - 48);
var _bh = sprite_get_height(spr_dialogue_box);
var _bx = (_w - _bw) / 2;
var _by = 720 - _bh - 24;
draw_sprite_stretched(spr_dialogue_box, 0, _bx, _by, _bw, _bh); // nine-slice

draw_set_font(global.dialogue_font);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
if (speaker != "") draw_text(_bx + 32, _by - 4, speaker);

draw_set_valign(fa_top);
var _text = dialogue[line];
draw_text_ext(_bx + 40, _by + 32, string_copy(_text, 1, floor(shown)), -1, _bw - 80);

// "Q" to continue, once the line is fully shown
if (shown >= string_length(_text))
{
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
	draw_text_transformed(_bx + _bw - 28, _by + _bh - 18 + sin(current_time / 200) * 2, "Q", 0.7, 0.7, 0);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
matrix_set(matrix_world, matrix_build_identity());
