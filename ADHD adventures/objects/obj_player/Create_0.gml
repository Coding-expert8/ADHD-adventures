// one-time setup: the player is created again in every room it enters
if (!variable_global_exists("character"))
{
	window_set_size(window_get_width() * 2, window_get_height() * 2)
	global.character = "1"
}
mask_index = spr_player_mask // feet only, so the body can overlap scenery drawn behind it
image_speed = 0.4
image_xscale = 0.4
image_yscale = 0.4
global.walking = "idle"
global.dialogue_npc = noone // no NPC talking (see obj_npc)

character_sprites = {
	"1": {
		"walk": {
			up: spr_char_1_walk_up, down: spr_char_1_walk_down, left: spr_char_1_walk_left, right: spr_char_1_walk_right
			}, 
		"idle": {
			up: spr_char_1_idle_up, down: spr_char_1_idle_down, left: spr_char_1_idle_left, right: spr_char_1_idle_right
			}
		}, 
	"2": {
		"walk": {
			up: spr_char_2_walk_up, down: spr_char_2_walk_down, left: spr_char_2_walk_left, right: spr_char_2_walk_right
			}, 
		"idle": {
			up: spr_char_2_idle_up, down: spr_char_2_idle_down, left: spr_char_2_idle_left, right: spr_char_2_idle_right
			}
		}, 
	"3": {
		"walk": {
			up: spr_char_3_walk_up, down: spr_char_3_walk_down, left: spr_char_3_walk_left, right: spr_char_3_walk_right
			}, 
		"idle": {
			up: spr_char_3_idle_up, down: spr_char_3_idle_down, left: spr_char_3_idle_left, right: spr_char_3_idle_right
			}
		}, 
	"4": {
		"walk": {
			up: spr_char_4_walk_up, down: spr_char_4_walk_down, left: spr_char_4_walk_left, right: spr_char_4_walk_right
			}, 
		"idle": {
			up: spr_char_4_idle_up, down: spr_char_4_idle_down, left: spr_char_4_idle_left, right: spr_char_4_idle_right
			}
		}, 
	"5": {
		"walk": {
			up: spr_char_5_walk_up, down: spr_char_5_walk_down, left: spr_char_5_walk_left, right: spr_char_5_walk_right
			}, 
		"idle": {
			up: spr_char_5_idle_up, down: spr_char_5_idle_down, left: spr_char_5_idle_left, right: spr_char_5_idle_right
			}
		}, 
	"6": {
		"walk": {
			up: spr_char_6_walk_up, down: spr_char_6_walk_down, left: spr_char_6_walk_left, right: spr_char_6_walk_right
			}, 
		"idle": {
			up: spr_char_6_idle_up, down: spr_char_6_idle_down, left: spr_char_6_idle_left, right: spr_char_6_idle_right
			}
		}, 
}

// answer-block minigame state (obj_lifejacket, falling off the blocks)
is_dead = false
floating_up = false
float_target_y = 0

// the answer-block minigame rooms still use the original player sprites at full size
if (room == room_main or room == room_answer)
{
	mask_index = -1
	image_xscale = 1
	image_yscale = 1
	sprite_index = spr_player_idle
	image_speed = 0
}
