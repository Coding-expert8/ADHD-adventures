if (boss_state == "defeated")
{
    alarm[1] = -1;
    exit;
}

if (health <= 100 && instance_exists(obj_player))
{
    var shadow_x = obj_player.x;
    var shadow_y = obj_player.bbox_bottom - 8;

    instance_create_layer(shadow_x, shadow_y, "Instances", obj_boss_shadow_circle);

    alarm[1] = 240;
}
else
{
    alarm[1] = 120;
}