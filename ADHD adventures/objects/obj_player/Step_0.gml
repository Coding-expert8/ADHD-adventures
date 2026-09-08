image_speed = 0.1
if keyboard_check(vk_right){
	x = x + (keyboard_check(vk_shift) ? 6 : 3)
}

if keyboard_check(vk_left){
	x = x - (keyboard_check(vk_shift) ? 6 : 3)
}

if keyboard_check(vk_up){
	y = y - (keyboard_check(vk_shift) ? 6 : 3)
}

if keyboard_check(vk_down){
	y = y + (keyboard_check(vk_shift) ? 6 : 3)
}

if (keyboard_check(vk_up)){
	image_speed = 0.4
	sprite_index = character_sprites[$ global.character][$ global.walking].up
} else if (keyboard_check(vk_down)){
	image_speed = 0.4
	sprite_index = character_sprites[$ global.character][$ global.walking].down
} else if (keyboard_check(vk_left)){
	image_speed = 0.4
	sprite_index = character_sprites[$ global.character][$ global.walking].left
} else if (keyboard_check(vk_right)){
	image_speed = 0.4
	sprite_index = character_sprites[$ global.character][$ global.walking].right
}