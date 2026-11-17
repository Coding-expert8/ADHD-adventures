display_set_gui_size(1366,768);

draw_set_font(fnt_score);

if room == room_map {
	if global.coin > 1 {
		draw_text_colour(x,y,"Coins " + string(global.coin), colour, colour, colour, colour, 1);
	}
	else if global.coin = 1 {
		draw_text_colour(x,y,"1 coin", colour, colour, colour, colour, 1);
	}
	else {
		draw_text_colour(x,y,"0 coins", colour, colour, colour, colour, 1);
	}
	draw_self();
}