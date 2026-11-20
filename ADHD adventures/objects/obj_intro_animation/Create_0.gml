// Check whether the intro animation has already played

var file_name = "animation_data.ini";

// Check whether the intro animation has already played

if (file_exists("animation_data.ini"))
{
    ini_open("animation_data.ini");

    global.intro_played = ini_read_real(
        "Game",
        "intro_played",
        0
    );

    ini_close();
}
else
{
    global.intro_played = 0;
}

// If animation has already played, skip to map
if (global.intro_played == 2)
{
    room_goto(room_map);
}
else
{
image_index = 0;
image_speed = 0;

// Fade settings
fade_alpha = 1;
fade_speed = 0.02;

// Animation settings
animation_started = false;

// Animation playback speed
animation_speed = 0.5;

// Final frame pause (in steps)
final_frame_delay = 120;
final_frame_timer = 0;
}