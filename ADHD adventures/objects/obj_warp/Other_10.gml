if (!room_exists(target_room)) exit
global.spawn_id = target_spawn
room_goto(target_room)
