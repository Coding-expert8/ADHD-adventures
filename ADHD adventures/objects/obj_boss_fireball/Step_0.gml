// Destroy outside room
if (x < 0 || x > room_width ||
    y < 0 || y > room_height)
{
    instance_destroy();
    exit;
}

// Check player collision
if (place_meeting(x, y, obj_player))
{
    // Player damage will be connected
    // to the existing player health system.

    instance_destroy();
}