// Major NPC: talks, then sends the player into the minigame.
sprite_index = spr_char_2_idle_down;
speaker      = "Rook";
dialogue     = [
	"Oh! A visitor!",
	"I set up a chess board, but nobody in town will play me.",
	"Beat me and the town key is yours!",
];
target_room  = room_tinyhouse_help;
star_colour  = make_color_rgb(185, 110, 255); // purple: chess
