global.lava_parkour_beaten = true;
audio_stop_sound(snd_fire_crackling);
global.coin += global.coins
room_goto(room_map);
minigame_win("lava_parkour_beaten");

