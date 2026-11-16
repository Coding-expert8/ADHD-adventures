draw_set_font(fnt_title);
draw_text(x,y-75,"Piece type");
draw_self();


if (global.game_over) {
   if global.winner == COLOR_WHITE {
	   global.tinyhouse_beaten = true;
   }
}