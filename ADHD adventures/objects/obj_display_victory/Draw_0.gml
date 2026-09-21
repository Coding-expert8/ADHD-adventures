draw_set_font(fnt_score);



draw_text(x,y,"Score: " + string(score));
draw_text(x,y+100,"Time taken: " + string(global.time));
draw_text(x,y+200,"Accuracy: " + string(global.accuracy) + "%");
draw_text(x,y+300,"Press 'H' to return");