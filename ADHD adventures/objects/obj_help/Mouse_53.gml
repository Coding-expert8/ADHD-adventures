var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var gw = display_get_gui_width();
var gh = display_get_gui_height();

if (!help_open)
{
    // Open HELP
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

    // Close X
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

    // PAGE NAVIGATION
    else if (active_tab == 1)
    {
        // Previous page
        if (mx >= left + 100 && mx <= left + 140 &&
            my >= top + 235 && my <= top + 265)
        {
            help_page = max(1, help_page - 1);
        }

        // Next page
        else if (mx >= left + 280 && mx <= left + 320 &&
                 my >= top + 235 && my <= top + 265)
        {
            help_page = min(2, help_page + 1);
        }
    }
}