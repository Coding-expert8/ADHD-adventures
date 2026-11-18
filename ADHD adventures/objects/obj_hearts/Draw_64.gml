if room = room_map {
	if global.hearts = 6 {
		draw_sprite(spr_heart, 0, x, y-offset);
		draw_sprite(spr_heart, 0, x+offset*2, y-offset);
		draw_sprite(spr_heart, 0, x+offset*4, y-offset);
	}
	else if global.hearts = 5 {
		draw_sprite(spr_heart, 0, x, y-offset);
		draw_sprite(spr_heart, 0, x+offset*2, y-offset);
		draw_sprite(spr_heart, 1, x+offset*4, y-offset);	
	}
	else if global.hearts = 4 {
		draw_sprite(spr_heart, 0, x, y-offset);
		draw_sprite(spr_heart, 0, x+offset*2, y-offset);
	}
	else if global.hearts = 3 {
		draw_sprite(spr_heart, 0, x, y-offset);
		draw_sprite(spr_heart, 1, x+offset*2, y-offset);
	}
	else if global.hearts = 2 {
		draw_sprite(spr_heart, 0, x, y-offset);
	}
	else if global.hearts = 1 {
		draw_sprite(spr_heart, 1, x, y-offset);
	}
	else {
		draw_text(x+offset,y,"You died")
		if (alarm[0] < 0) alarm[0] = 60; // start the countdown once, not every frame
	}
}
