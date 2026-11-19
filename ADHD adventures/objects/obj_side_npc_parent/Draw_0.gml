/// obj_side_npc_parent - DRAW

draw_self();

if (global.dialogue_npc != noone) exit;

var p = instance_find(obj_player, 0);

if (p != noone && distance_to_object(p) <= talk_range)
{
    draw_set_font(global.dialogue_font);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);

    draw_text(
        x,
        bbox_top - 8 + sin(current_time / 200) * 2,
        "Q"
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
}