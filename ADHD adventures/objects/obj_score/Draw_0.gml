/// @DnDAction : YoYo Games.Common.Temp_Variable
/// @DnDVersion : 1
/// @DnDHash : 60C5E658
/// @DnDArgument : "var" "vc"
/// @DnDArgument : "value" "view_camera[0]"
var vc = view_camera[0];

/// @DnDAction : YoYo Games.Common.Temp_Variable
/// @DnDVersion : 1
/// @DnDHash : 7F5ECB19
/// @DnDArgument : "var" "cx"
/// @DnDArgument : "value" "camera_get_view_x(vc)"
var cx = camera_get_view_x(vc);

/// @DnDAction : YoYo Games.Common.Temp_Variable
/// @DnDVersion : 1
/// @DnDHash : 581E68AB
/// @DnDArgument : "var" "cy"
/// @DnDArgument : "value" "camera_get_view_y(vc)"
var cy = camera_get_view_y(vc);

/// @DnDAction : YoYo Games.Common.Temp_Variable
/// @DnDVersion : 1
/// @DnDHash : 2CDBC377
/// @DnDArgument : "var" "cw"
/// @DnDArgument : "value" "camera_get_view_width(vc)"
var cw = camera_get_view_width(vc);

/// @DnDAction : YoYo Games.Drawing.Set_Font
/// @DnDVersion : 1
/// @DnDHash : 2E30BB85
/// @DnDArgument : "font" "fnt_score"
/// @DnDSaveInfo : "font" "fnt_score"
draw_set_font(fnt_score);

/// @DnDAction : YoYo Games.Drawing.Set_Color
/// @DnDVersion : 1
/// @DnDHash : 68F45B1D
/// @DnDArgument : "alpha" "false"
draw_set_colour($FFFFFFFF & $ffffff);draw_set_alpha(1);

/// @DnDAction : YoYo Games.Drawing.Draw_Value
/// @DnDVersion : 1
/// @DnDHash : 4CBE1A99
/// @DnDArgument : "x" "cx + (cw / 2)"
/// @DnDArgument : "y" "cy + 25"
/// @DnDArgument : "caption" """"
/// @DnDArgument : "var" "thescore"
draw_text(cx + (cw / 2), cy + 25, string("") + string(thescore));