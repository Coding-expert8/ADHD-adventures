display_set_gui_size(1366,700);
colour = c_aqua;
draw_set_font(fnt_score);
draw_text_colour(x,y,"Coins: " + string(global.coins),colour,colour,colour,colour,0.5);

draw_text_colour(x,y+50,"Lives: " + string(global.lava_lives),colour,colour,colour,colour,0.5);