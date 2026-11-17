if (global.dialogue_npc != id) exit;

// lay out in 720p units and scale to whatever the GUI size is (SDF text stays sharp)
var _s = display_get_gui_height() / 720;
var _w = display_get_gui_width() / _s;
matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _s, _s, 1));

var _bw = min(sprite_get_width(spr_dialogue_box), _w - 48);
var _text = dialogue[line];

// Wrap the whole line up front: each space becomes either " " or a line break, so the
// typewriter can show the first `shown` characters and words never jump to the next
// line halfway through being typed.
draw_set_font(global.dialogue_text_font);
var _max_w   = _bw - 80;
var _words   = string_split(_text, " ");
var _wrapped = "";
var _row     = "";
for (var _i = 0; _i < array_length(_words); _i++)
{
	var _try = (_i == 0) ? _words[_i] : _row + " " + _words[_i];
	if (_i > 0 and string_width(_try) > _max_w)
	{
		_wrapped += _row + "\n";
		_row = _words[_i];
	}
	else _row = _try;
}
_wrapped += _row;

// the box grows taller when a line wraps onto more rows than it fits (nine-slice stretches)
var _bh = max(sprite_get_height(spr_dialogue_box), string_height(_wrapped) + 64);
var _bx = (_w - _bw) / 2;
var _by = 720 - _bh - 24;
draw_sprite_stretched(spr_dialogue_box, 0, _bx, _by, _bw, _bh); // nine-slice

draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(_bx + 40, _by + 28, string_copy(_wrapped, 1, floor(shown)));

draw_set_font(global.dialogue_font);
draw_set_valign(fa_bottom);
if (speaker != "") draw_text(_bx + 32, _by - 4, speaker);

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
