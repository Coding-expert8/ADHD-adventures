// Fade in from black
if (!animation_started)
{
    fade_alpha -= fade_speed;

    if (fade_alpha <= 0)
    {
        fade_alpha = 0;

        // Start animation once fully visible
        animation_started = true;
        image_speed = animation_speed;
    }
}

// Check whether animation has finished
if (animation_started)
{
    if (image_index >= image_number - 1)
    {
        // Hold on the final frame
        image_speed = 0;
        image_index = image_number - 1;

        // Start final frame timer
        final_frame_timer++;

        // Wait before transitioning
        if (final_frame_timer >= final_frame_delay)
        {
            // Save animation completion to INI file
            ini_open("animation_data_final.ini");

            ini_write_real(
                "Game",
                "final_played",
                1
            );

            ini_close();

            // Go to map room
            room_goto(room_map);
        }
    }
}