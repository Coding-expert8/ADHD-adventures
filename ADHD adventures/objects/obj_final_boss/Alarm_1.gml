if (boss_state == "defeated")
{
    exit;
}

if (health > 50)
{
    alarm[1] = 180;
    exit;
}

// Target player's current position
if (instance_exists(obj_player))
{
    instance_create_layer(
        obj_player.x,
        obj_player.y,
        "Instances",
        obj_boss_shadow_circle
    );
}

// Schedule next shadow attack
alarm[1] = 240;