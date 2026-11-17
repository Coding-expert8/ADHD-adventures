if room == room_space_rocks
{
if score >= 100000
	{
		room_goto(room_start);
	}
if lives <= 0 and (!activated)
	{
		alarm[2] = room_speed;
		activated = true;
	}
}


