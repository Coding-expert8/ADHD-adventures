

draw_set_font(fnt_space_rocks_title);
draw_text_colour(x,y,"Tinyhouse chess",c_blue,c_blue,c_red,c_red,0.9);
draw_set_font(fnt_score);
draw_set_colour(c_fuchsia);
draw_text(x,y+250,"Click pieces to select and move");
draw_text(x,y+300,"Pieces represented as letters as such:");
draw_text(x,y+350,"K: King: Same as chess");
draw_text(x,y+400,"P: Pawn: Same as chess");
draw_text(x,y+450,"W: Wazir:Moves one step horizontally")
draw_text(x,y+500,"F: Ferz: Moves one step diagonally");
draw_text(x,y+550,"H: Horse; like chess, can't jump over pieces")
draw_text(x,y+600,"Captured pieces can be placed back onto the board (WIP)")
draw_text(x,y+650,"Press Q to play");
