if (jump_released) {
    motion_set(image_angle + 90, max(vspeed, jump/3));
}
counter += 1;
if counter <= 15 {
	alarm[2] = 1;
}