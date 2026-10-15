room_restart();
if lives <= 2
{
	alarm[2] = room_speed;
	room_goto(room_death_space_rocks);
}