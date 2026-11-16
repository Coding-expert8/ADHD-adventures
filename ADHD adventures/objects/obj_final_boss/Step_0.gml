// Stop if defeated
if (boss_state == "defeated")
{
    exit;
}

// Handle hurt animation
if (boss_state == "hurt")
{
    hurt_timer -= 1;

    if (hurt_timer <= 0)
    {
        boss_state = "move";
        sprite_index = spr_boss_move;
        image_index = 0;
        image_speed = 0.15;
    }

    exit;
}

// Horizontal movement
x += move_speed * move_direction;

// Screen boundaries
if (x > room_width - 80)
{
    move_direction = -1;
}

if (x < 80)
{
    move_direction = 1;
}

// Don't interrupt the attack animation
if (boss_state == "attack")
{
    if (image_index >= image_number - 1)
    {
        boss_state = "move";
        sprite_index = spr_boss_move;
        image_index = 0;
        image_speed = 0.15;
    }

    exit;
}

// Normal movement animation
boss_state = "move";
sprite_index = spr_boss_move;
image_speed = 0.15;

// Second phase
if (health <= 50)
{
    move_speed = 3;
    attack_cooldown = 55;
}