/// obj_side_npc_parent - DRAW GUI

if (global.dialogue_npc != id) exit;

var s = display_get_gui_height() / 720;
var w = display_get_gui_width() / s;

matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, s, s, 1));

var bw = min(sprite_get_width(spr_dialogue_box), w - 48);
var bh = sprite_get_height(spr_dialogue_box);

var bx = (w - bw) / 2;
var by = 720 - bh - 24;

// Draw existing dialogue box
draw_sprite_stretched(spr_dialogue_box, 0, bx, by, bw, bh);

draw_set_font(global.dialogue_font);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);

// NPC name
draw_text(bx + 32, by - 4, speaker);

// Dialogue
draw_set_valign(fa_top);

var shown_text = string_copy(dialogue[line], 1, floor(shown));

draw_text_ext(
    bx + 40,
    by + 32,
    shown_text,
    -1,
    bw - 80
);

// Continue prompt
if (shown >= string_length(dialogue[line]))
{
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);

    draw_text_transformed(
        bx + bw - 28,
        by + bh - 18 + sin(current_time / 200) * 2,
        "Q",
        0.7,
        0.7,
        0
    );
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);

matrix_set(matrix_world, matrix_build_identity());