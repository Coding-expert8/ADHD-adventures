if place_meeting(x,y,obj_platform)  and (_up)
{
	motion_set(image_angle + 90, jump);
}
else if place_meeting(x,y,obj_platform)
{
	motion_set(image_angle + 90, 0);
	gravity = 0;
}
jumped = false;