if (!popup_open) exit;

var gw = display_get_gui_width();
var gh = display_get_gui_height();

var scale = 0.7;

var board_w = 540 * scale;
var board_h = 350 * scale;

var left = (gw - board_w) / 2;
var top = (gh - board_h) / 2;

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

if (mouse_check_button_pressed(mb_left))
{
    // Close button
    if (mx >= left + 485 * scale && mx <= left + 525 * scale &&
        my >= top + 12 * scale && my <= top + 52 * scale)
    {
        popup_open = false;
        input_active = false;
        exit;
    }

    // Username box
    if (mx >= left + 20 * scale && mx <= left + 520 * scale &&
        my >= top + 183 * scale && my <= top + 247 * scale)
    {
        input_active = true;
        keyboard_string = username_input;
    }
    else
    {
        input_active = false;
    }

    // SAVE button
    if (mx >= left + 20 * scale && mx <= left + 520 * scale &&
        my >= top + 263 * scale && my <= top + 327 * scale)
    {
        if (string_length(string_trim(username_input)) > 0)
        {
            global.username = string_trim(username_input);
            popup_open = false;
            input_active = false;
            save_game(); // keep the name in save.ini
        }
    }
}

if (input_active)
{
    username_input = keyboard_string;
}