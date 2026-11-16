// Room Start runs after the Creation Code has set `unlock`.
// room_map is rebuilt every time it is entered, so this check is all a gate needs.
if (unlock != "" and variable_global_exists(unlock) and variable_global_get(unlock) == true)
{
	instance_destroy();
}
