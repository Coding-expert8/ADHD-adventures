image_speed = 0

if keyboard_check(vk_right){
	image_speed = 1
	image_xscale = 1
	x = x+3
}
if keyboard_check(vk_up){
	image_speed = 1
	y = y-3
}
if keyboard_check(vk_down){
	image_speed = 1
	y = y+3
}
if keyboard_check(vk_left){
	image_xscale = -1
	image_speed = 1
	x = x-3
}