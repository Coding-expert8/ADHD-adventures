// "Game saved" note in the corner for a moment after pressing F5
if (saved_timer <= 0) exit;
saved_timer -= 1;

draw_set_alpha(min(1, saved_timer / 20));
draw_set_colour(c_white);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_text(display_get_gui_width() - 16, display_get_gui_height() - 16, "Game saved");
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
