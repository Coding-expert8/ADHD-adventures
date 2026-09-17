if room == room_space_rocks
{
if score >= 1000
	{
	room_goto(room_start);
	}
if lives <= 0
	{
	room_goto(room_start);
	}
}