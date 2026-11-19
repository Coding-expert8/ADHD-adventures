// ==============================
// SIDE QUEST NPC - DRAW GUI
// ==============================

if (global.dialogue_npc != id) exit;

// Scale to 720p GUI units
var _s = display_get_gui_height() / 720;
var _w = display_get_gui_width() / _s;

matrix_set(
    matrix_world,
    matrix_build(0, 0, 0, 0, 0, 0, _s, _s, 1)
);

var _bw = min(
    sprite_get_width(spr_dialogue_box),
    _w - 48
);

var _text = dialogue[line];

// Wrap dialogue
draw_set_font(global.dialogue_text_font);

var _max_w = _bw - 80;
var _words = string_split(_text, " ");
var _wrapped = "";
var _row = "";

for (var _i = 0; _i < array_length(_words); _i++)
{
    var _try = (_i == 0)
        ? _words[_i]
        : _row + " " + _words[_i];

    if (_i > 0 && string_width(_try) > _max_w)
    {
        _wrapped += _row + "\n";
        _row = _words[_i];
    }
    else
    {
        _row = _try;
    }
}

_wrapped += _row;

// Dialogue box height
var _bh = max(
    sprite_get_height(spr_dialogue_box),
    string_height(_wrapped) + 64
);

var _bx = (_w - _bw) / 2;
var _by = 720 - _bh - 24;

// Draw dialogue box using your existing system
adv_card(
    _bx,
    _by,
    _bw,
    _bh,
    global.adv_paper
);

// Dialogue text
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_text(
    _bx + 40,
    _by + 28,
    string_copy(
        _wrapped,
        1,
        floor(shown)
    )
);

// NPC name
draw_set_font(global.dialogue_font);
draw_set_valign(fa_bottom);

if (speaker != "")
{
    draw_text(
        _bx + 32,
        _by - 4,
        speaker
    );
}

// Q prompt
if (shown >= string_length(_text))
{
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);

    draw_text_transformed(
        _bx + _bw - 28,
        _by + _bh - 18 + sin(current_time / 200) * 2,
        "Q",
        0.7,
        0.7,
        0
    );
}

// Reset drawing settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);

matrix_set(
    matrix_world,
    matrix_build_identity()
);