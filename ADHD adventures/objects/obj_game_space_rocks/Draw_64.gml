display_set_gui_size(1366,768);

draw_set_font(fnt_score);
draw_set_colour(c_green);

draw_text(50, 20, "SCORE: " + string(score));
draw_text(50, 60, "LIVES: " + string(lives));