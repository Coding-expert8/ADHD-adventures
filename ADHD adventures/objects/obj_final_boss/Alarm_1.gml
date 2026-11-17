if (boss_state == "defeated" || boss_state == "hurt")
{
    alarm[1] = 60;
    exit;
}

if (health <= 50 && instance_exists(obj_player))
{
    instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_boss_shadow_circle);
}

alarm[1] = 240;