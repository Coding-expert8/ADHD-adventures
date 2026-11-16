if (instance_exists(obj_player))
{
    var target_direction = point_direction(
        x, y,
        obj_player.x, obj_player.y
    );

    var b1 = instance_create_layer(
        x, y + 40,
        "Instances",
        obj_boss_fireball
    );

    b1.direction = target_direction;
}