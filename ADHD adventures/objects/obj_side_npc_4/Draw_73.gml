// ==============================
// SIDE QUEST NPC - DRAW END
// ==============================

// Don't show prompt while another NPC is talking
if (instance_exists(global.dialogue_npc)) exit;

// Must have a player
if (!instance_exists(obj_player)) exit;

// Player must be nearby
if (distance_to_object(obj_player) > talk_range) exit;

// Floating Q prompt
draw_set_font(global.dialogue_font);
draw_set_colour(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);

draw_text_transformed(
    (bbox_left + bbox_right) / 2,
    bbox_top - 2 + sin(current_time / 200) * 2,
    "Q",
    0.8,
    0.8,
    0
);

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);