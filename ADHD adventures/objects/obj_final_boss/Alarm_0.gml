if (boss_state == "defeated" || boss_state == "hurt")
{
    alarm[0] = 30;
    exit;
}

if (instance_exists(obj_player))
{
    boss_state = "attack";
    sprite_index = spr_boss_attack;
    image_index = 0;
    image_speed = 0.2;

    var target_direction = point_direction(x, y, obj_player.x, obj_player.y);

    if (health > 50)
    {
		audio_play_sound(snd_bossfire, 1, false)
        var b1 = instance_create_layer(x, y + 40, "Instances", obj_boss_fireball);
        b1.direction = target_direction;
    }
    else
    {
		audio_play_sound(snd_bossfire, 1, false)
        var b1 = instance_create_layer(x, y + 40, "Instances", obj_boss_fireball);
        b1.direction = target_direction - 20;

        var b2 = instance_create_layer(x, y + 40, "Instances", obj_boss_fireball);
        b2.direction = target_direction;

        var b3 = instance_create_layer(x, y + 40, "Instances", obj_boss_fireball);
        b3.direction = target_direction + 20;
    }
}

if (health > 50)
{
    alarm[0] = 90;
}
else
{
    alarm[0] = 55;
}