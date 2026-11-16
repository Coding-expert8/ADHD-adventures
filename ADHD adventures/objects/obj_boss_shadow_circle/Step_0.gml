if (active && instance_exists(obj_player))
{
    if (place_meeting(x, y, obj_player))
    {
        obj_player.hp -= 10

        // Prevent repeated damage during this attack
        instance_destroy();
    }
}