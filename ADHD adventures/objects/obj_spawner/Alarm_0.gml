/// @DnDAction : YoYo Games.Random.Get_Random_Number
/// @DnDVersion : 1
/// @DnDHash : 5AF32E17
/// @DnDArgument : "var" "xx"
/// @DnDArgument : "max" "room_width"
xx = (random_range(0, room_width));

/// @DnDAction : YoYo Games.Random.Get_Random_Number
/// @DnDVersion : 1
/// @DnDHash : 63EF375F
/// @DnDArgument : "var" "yy"
/// @DnDArgument : "max" "room_height"
yy = (random_range(0, room_height));

/// @DnDAction : YoYo Games.Instances.Create_Instance
/// @DnDVersion : 1
/// @DnDHash : 52169694
/// @DnDArgument : "xpos" "xx"
/// @DnDArgument : "ypos" "yy"
/// @DnDArgument : "objectid" "obj_enemyspawn"
/// @DnDArgument : "layer" ""Enemy_layer""
/// @DnDSaveInfo : "objectid" "obj_enemyspawn"
instance_create_layer(xx, yy, "Enemy_layer", obj_enemyspawn);

/// @DnDAction : YoYo Games.Instances.Set_Alarm
/// @DnDVersion : 1
/// @DnDHash : 3DC1B5B8
/// @DnDArgument : "steps" "spawn_rate"
alarm_set(0, spawn_rate);