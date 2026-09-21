display_set_gui_size(1366,768)

draw_set_font(fnt_score)

global.accuracy = global.shots_landed / global.shots_fired * 100
draw_text(x,y,"Accuracy: " + string(global.accuracy) + "%")

if global.time <= 60 {
	draw_text(x-125,y+50,"Time elapsed: " + string(global.time) + " seconds")
}
else {
	word = "Time elapsed: " + string(floor(global.time/60)) + " minutes and " + string(global.time - floor(time/60) * 60) + " seconds"
	draw_text(x-380,y+50,word)
}
