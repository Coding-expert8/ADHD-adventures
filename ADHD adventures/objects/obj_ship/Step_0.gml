if (keyboard_check(vk_left) or keyboard_check(ord("A")))
{
image_angle = image_angle + 5
}

if (keyboard_check(vk_right) or keyboard_check(ord("D")))
{
image_angle = image_angle - 5
}

if (keyboard_check(vk_up) or keyboard_check(ord("W")))
{
motion_add(image_angle, 0.05)
moving = true
}

angle = image_angle mod 360
image_angle = angle

if angle > 90 and angle < 270
{
	image_yscale = -1

}
else
{

	image_yscale = 1
}
if image_angle < 0 {
	image_angle = 360
}