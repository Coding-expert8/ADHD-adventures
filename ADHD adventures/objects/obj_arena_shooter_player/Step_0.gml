/// @DnDAction : YoYo Games.Mouse & Keyboard.If_Key_Down
/// @DnDVersion : 1
/// @DnDHash : 0A86E227
/// @DnDArgument : "key" "vk_right"
var l0A86E227_0;
l0A86E227_0 = keyboard_check(vk_right);
if (l0A86E227_0)
{
	/// @DnDAction : YoYo Games.Common.Variable
	/// @DnDVersion : 1
	/// @DnDHash : 395DE861
	/// @DnDParent : 0A86E227
	/// @DnDArgument : "expr" "4"
	/// @DnDArgument : "expr_relative" "1"
	/// @DnDArgument : "var" "x"
	x += 4;
}

/// @DnDAction : YoYo Games.Mouse & Keyboard.If_Key_Down
/// @DnDVersion : 1
/// @DnDHash : 28EBBAA3
/// @DnDArgument : "key" "vk_left"
var l28EBBAA3_0;
l28EBBAA3_0 = keyboard_check(vk_left);
if (l28EBBAA3_0)
{
	/// @DnDAction : YoYo Games.Common.Variable
	/// @DnDVersion : 1
	/// @DnDHash : 6C37EE2B
	/// @DnDParent : 28EBBAA3
	/// @DnDArgument : "expr" "-4"
	/// @DnDArgument : "expr_relative" "1"
	/// @DnDArgument : "var" "x"
	x += -4;
}

/// @DnDAction : YoYo Games.Mouse & Keyboard.If_Key_Down
/// @DnDVersion : 1
/// @DnDHash : 0257E18A
/// @DnDArgument : "key" "vk_up"
var l0257E18A_0;
l0257E18A_0 = keyboard_check(vk_up);
if (l0257E18A_0)
{
	/// @DnDAction : YoYo Games.Common.Variable
	/// @DnDVersion : 1
	/// @DnDHash : 68F4BCA2
	/// @DnDParent : 0257E18A
	/// @DnDArgument : "expr" "-4"
	/// @DnDArgument : "expr_relative" "1"
	/// @DnDArgument : "var" "y"
	y += -4;
}

/// @DnDAction : YoYo Games.Mouse & Keyboard.If_Key_Down
/// @DnDVersion : 1
/// @DnDHash : 5ABEE557
/// @DnDArgument : "key" "vk_down"
var l5ABEE557_0;
l5ABEE557_0 = keyboard_check(vk_down);
if (l5ABEE557_0)
{
	/// @DnDAction : YoYo Games.Common.Variable
	/// @DnDVersion : 1
	/// @DnDHash : 30EEA196
	/// @DnDParent : 5ABEE557
	/// @DnDArgument : "expr" "4"
	/// @DnDArgument : "expr_relative" "1"
	/// @DnDArgument : "var" "y"
	y += 4;
}

/// @DnDAction : YoYo Games.Common.Temp_Variable
/// @DnDVersion : 1
/// @DnDHash : 464C4DC1
/// @DnDArgument : "var" "dir"
/// @DnDArgument : "value" "point_direction(x, y, mouse_x, mouse_y)"
var dir = point_direction(x, y, mouse_x, mouse_y);

/// @DnDAction : YoYo Games.Instances.Sprite_Rotate
/// @DnDVersion : 1
/// @DnDHash : 38EDE504
/// @DnDArgument : "angle" "dir"
image_angle = dir;

/// @DnDAction : YoYo Games.Mouse & Keyboard.If_Mouse_Down
/// @DnDVersion : 1.1
/// @DnDHash : 073E9977
var l073E9977_0;
l073E9977_0 = mouse_check_button(mb_left);
if (l073E9977_0)
{
	/// @DnDAction : YoYo Games.Common.If_Variable
	/// @DnDVersion : 1
	/// @DnDHash : 0A17C432
	/// @DnDParent : 073E9977
	/// @DnDArgument : "var" "cooldown"
	/// @DnDArgument : "op" "1"
	/// @DnDArgument : "value" "1"
	if(cooldown < 1)
	{
		/// @DnDAction : YoYo Games.Instances.Create_Instance
		/// @DnDVersion : 1
		/// @DnDHash : 61583195
		/// @DnDParent : 0A17C432
		/// @DnDArgument : "xpos" "x"
		/// @DnDArgument : "ypos" "y"
		/// @DnDArgument : "objectid" "obj_bullet"
		/// @DnDArgument : "layer" ""Bullets_Layer""
		/// @DnDSaveInfo : "objectid" "obj_bullet"
		instance_create_layer(x, y, "Bullets_Layer", obj_arena_shooter_bullet);
	
		/// @DnDAction : YoYo Games.Common.Variable
		/// @DnDVersion : 1
		/// @DnDHash : 229558E7
		/// @DnDParent : 0A17C432
		/// @DnDArgument : "expr" "10"
		/// @DnDArgument : "var" "cooldown"
		cooldown = 10;
	}
}

/// @DnDAction : YoYo Games.Common.Variable
/// @DnDVersion : 1
/// @DnDHash : 5DFE3353
/// @DnDArgument : "expr" "-1"
/// @DnDArgument : "expr_relative" "1"
/// @DnDArgument : "var" "cooldown"
cooldown += -1;