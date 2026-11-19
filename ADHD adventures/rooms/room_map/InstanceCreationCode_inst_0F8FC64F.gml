// Major NPC: talks, then sends the player into the minigame.
sprite_index = spr_char_5_idle_down;
speaker      = "Frost";
dialogue     = [
	"Brrr! Ice rocks keep crashing down the mountain.",
	"Take my ship up there and blast them to bits!",
];
target_room  = room_space_rocks;
star_colour  = make_color_rgb(150, 230, 255); // icy blue: ice rocks
