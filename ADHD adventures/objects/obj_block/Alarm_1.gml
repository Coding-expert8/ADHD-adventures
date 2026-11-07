y += 8
image_alpha -= 0.1
if (image_alpha <= 0) {
	instance_destroy()
} else {
	alarm[1] = 1
}