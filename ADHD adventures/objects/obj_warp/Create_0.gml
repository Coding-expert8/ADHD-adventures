// Door or exit. Walking in takes the player to the obj_spawn whose spawn_id matches target_spawn
// in target_room. Set both per instance in the room editor (Variable Definitions or Creation Code).
if (!variable_instance_exists(id, "target_room")) target_room = noone;
if (!variable_instance_exists(id, "target_spawn")) target_spawn = "";
