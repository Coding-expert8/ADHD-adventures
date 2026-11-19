// Major NPC: talks, then sends the player into the minigame.
sprite_index = spr_char_6_idle_down;
speaker      = "Ember";
dialogue     = [
	"Careful, the floor is lava. Really.",
	"Climb all the way to the top without falling in!",
];
target_room  = room_lava_parkour_help;
star_colour  = make_color_rgb(255, 85, 30); // lava orange: lava parkour
