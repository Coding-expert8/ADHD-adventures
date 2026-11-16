// Defeated: allow defeat animation to finish
if (boss_state == "defeated")
{
    image_speed = 0.15;

    if (image_index >= image_number - 1)
    {
        image_speed = 0;
        image_index = image_number - 1;
    }

    exit;
}

// Hurt animation
if (boss_state == "hurt")
{
    hurt_timer--;

    if (hurt_timer <= 0)
    {
        boss_state = "idle";
        image_speed = 0.15;
    }

    exit;
}

// Attack animation: do not interrupt it
if (boss_state == "attack")
{
    if (image_index >= image_number - 1)
    {
        boss_state = "idle";
        image_speed = 0.15;
    }

    exit;
}

// Death check
if (health <= 0)
{
    health = 0;
    boss_state = "defeated";
    sprite_index = spr_boss_defeat;
    image_index = 0;
    image_speed = 0.15;
    alarm[0] = -1;
    alarm[1] = -1;
    exit;
}

// Player tracking and movement
if (instance_exists(obj_player))
{
    var target_x = obj_player.x;
    var target_y = obj_player.y - orbit_distance;

    var current_speed = move_speed;

    if (health <= 50)
    {
        current_speed = move_speed * 1.5;
    }

    move_timer--;

    if (move_timer <= 0 && dash_timer <= 0)
    {
        move_state = irandom_range(0, 2);

        move_timer = irandom_range(60, 120);

        if (health <= 50)
        {
            move_timer = irandom_range(35, 75);
        }

        move_target_x = target_x + irandom_range(-180, 180);
        move_target_y = target_y + irandom_range(-100, 100);
    }

    // Track player
    if (move_state == 0)
    {
        x = lerp(x, target_x, 0.025 * current_speed);
        y = lerp(y, target_y, 0.025 * current_speed);
    }

    // Reposition around player
    if (move_state == 1)
    {
        x = lerp(x, move_target_x, 0.035 * current_speed);
        y = lerp(y, move_target_y, 0.035 * current_speed);
    }

    // Dash towards player's position
    if (move_state == 2)
    {
        if (dash_timer <= 0)
        {
            dash_timer = 20;
            move_target_x = target_x;
            move_target_y = target_y;
        }

        var dash_direction = point_direction(x, y, move_target_x, move_target_y);

        x += lengthdir_x(dash_speed * current_speed / move_speed, dash_direction);
        y += lengthdir_y(dash_speed * current_speed / move_speed, dash_direction);

        dash_timer--;

        if (dash_timer <= 0)
        {
            move_state = 0;
            move_timer = 60;
        }
    }

    x = clamp(x, 80, room_width - 80);
    y = clamp(y, 50, room_height - 100);
}

// Keep idle animation running
if (boss_state == "idle")
{
    sprite_index = spr_boss_idle;
    image_speed = 0.15;
}