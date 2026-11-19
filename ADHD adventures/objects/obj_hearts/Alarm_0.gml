global.space_rocks_beaten = false;
global.tinyhouse_beaten = false;
global.lava_parkour_beaten = false;
global.bridge_beaten = false;
global.snake_beaten = false;
global.fishing_beaten = false;
room_goto(room_map);
global.hearts = 6;
activated = false;
room_restart();
// "You died" has been shown: lost all hearts, so the whole save is wiped (progress, keys,
// coins, name, discovered areas, play time) and a new game starts in the village.
reset_save();
restart_on_map();
