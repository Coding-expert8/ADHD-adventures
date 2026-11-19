// Ignore hits during defeat
if (boss_state == "defeated")
{
    exit;
}

// Ignore repeated hits during hurt animation
if (boss_state == "hurt")
{
    with (other)
    {
        instance_destroy();
    }

    exit;
}

// Reduce health
health -= other.damage;

// Spawn impact effect
instance_create_layer(x, y,"Instances", obj_boss_hit_effect);

// Hurt animation
if (health > 0)
{
    boss_state = "hurt";

    sprite_index = spr_boss_hurt;
    image_index = 0;
    image_speed = 0.2;

    hurt_timer = 20;

    // Delay next attack
    alarm[0] = 20;
}
else
{
    health = 0;

    boss_state = "defeated";

    sprite_index = spr_boss_defeat;
    image_index = 0;
    image_speed = 0.15;

    // Stop future attacks
    alarm[0] = -1;
    alarm[1] = -1;
}

with (other)
{
    instance_destroy();
}