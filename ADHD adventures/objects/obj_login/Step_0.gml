if (!popup_open)
{
    exit;
}

// Get GUI dimensions
var gw = display_get_gui_width();
var gh = display_get_gui_height();

// Centre the popup
var board_w = 540;
var board_h = 350;

var left = (gw - board_w) / 2;
var top = (gh - board_h) / 2;

// Close button
if (mouse_check_button_pressed(mb_left))
{
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);

    // X button
    if (mx >= left + 485 && mx <= left + 525 &&
        my >= top + 15 && my <= top + 55)
    {
        popup_open = false;
        input_active = false;
        exit;
    }

    // Username box
    if (mx >= left + 35 && mx <= left + 505 &&
        my >= top + 180 && my <= top + 245)
    {
        input_active = true;
        keyboard_string = username_input;
    }
    else
    {
        input_active = false;
    }

    // SAVE button
    if (mx >= left + 35 && mx <= left + 505 &&
        my >= top + 260 && my <= top + 325)
    {
        if (string_length(string_trim(username_input)) > 0)
        {
            global.username = string_trim(username_input);
            popup_open = false;
            input_active = false;
        }
    }
}

// Update username
if (input_active)
{
    username_input = keyboard_string;
}