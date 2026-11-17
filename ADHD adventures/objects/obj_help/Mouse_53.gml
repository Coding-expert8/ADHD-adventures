
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var gw = display_get_gui_width();
var gh = display_get_gui_height();

// HELP button
if (!help_open)
{
    if (mx >= 25 && mx <= 135 &&
        my >= 20 && my <= 55)
    {
        help_open = true;
        active_tab = 1;
        help_page = 1;
    }
}
else
{
    var board_w = 420;
    var board_h = 280;

    var left = (gw - board_w) / 2;
    var top = (gh - board_h) / 2;

    // Close button
    if (mx >= left + board_w - 35 && mx <= left + board_w - 10 &&
        my >= top + 10 && my <= top + 35)
    {
        help_open = false;
    }

    // HOW TO PLAY TAB
    else if (mx >= left + 25 && mx <= left + 205 &&
             my >= top - 27 && my <= top + 15)
    {
        active_tab = 1;
    }

    // TELEPORTATION TAB
    else if (mx >= left + 215 && mx <= left + 395 &&
             my >= top - 27 && my <= top + 15)
    {
        active_tab = 2;
    }

    // HOW TO PLAY PAGE ARROWS
    else if (active_tab == 1)
    {
        if (mx >= left + 100 && mx <= left + 140 &&
            my >= top + 235 && my <= top + 265)
        {
            help_page = max(1, help_page - 1);
        }
        else if (mx >= left + 280 && mx <= left + 320 &&
                 my >= top + 235 && my <= top + 265)
        {
            help_page = min(2, help_page + 1);
        }
    }

    // TELEPORTATION MAP CLICK
    else if (active_tab == 2)
    {
        // Fixed outer frame
        var map_x = left + 90;
        var map_y = top + 65;

        // Image shifted 27 pixels left
        var image_x = map_x - 27;

        // Only allow clicks inside the fixed frame
        if (mx >= map_x && mx <= map_x + 240 &&
            my >= map_y && my <= map_y + 158)
        {
            var map_click_x = mx - image_x;
            var map_click_y = my - map_y;

            // Convert image coordinates into room coordinates
            var destination_x = (map_click_x / 240) * 18000;
            var destination_y = (map_click_y / 158) * 12000;

            if (instance_exists(obj_player))
            {
                obj_player.x = destination_x;
                obj_player.y = destination_y;

                help_open = false;
            }
        }
    }
}
