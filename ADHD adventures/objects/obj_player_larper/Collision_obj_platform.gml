if (_platform && bbox_bottom <= other.bbox_top)  and (_up)
{
	motion_set(image_angle + 90, jump);
}
else if (_platform && bbox_bottom <= other.bbox_top)
{
	motion_set(image_angle + 90, 0);
	gravity = 0;
}
jumped = false;

