display_set_gui_size(1366,768);

draw_set_font(fnt_score);

global.accuracy = global.shots_landed / global.shots_fired * 100;
draw_text(x,y,"Accuracy: " + string(global.accuracy) + "%");

