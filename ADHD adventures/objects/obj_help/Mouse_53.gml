
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var gw = display_get_gui_width();
var gh = display_get_gui_height();

// HELP button (top right, left of CREDITS)
if (!help_open)
{
    var button_x = gw - 260;
    var button_y = 20;

    if (!pause_menu_open() and
        mx >= button_x and mx <= button_x + 110 and
        my >= button_y and my <= button_y + 35)
    {
        play_select();
        help_open = true;
        active_tab = 1;
        help_page = 1;
    }
}
else
{
    var board_w = 420;
    var board_h = 280;

    // same scale as the drawn board (Draw_64)
    var _s = menu_board_scale();
    mx /= _s;
    my /= _s;
    gw /= _s;
    gh /= _s;

    var left = (gw - board_w) / 2;
    var top = (gh - board_h) / 2;

    // Close button
    if (mx >= left + board_w - 35 and mx <= left + board_w - 10 and
        my >= top + 10 and my <= top + 35)
    {
        play_select();
        help_open = false;
    }

    // HOW TO PLAY TAB
    else if (mx >= left + 25 and mx <= left + 205 and
             my >= top - 27 and my <= top + 15)
    {
        play_select();
        active_tab = 1;
    }

    // TELEPORTATION TAB
    else if (mx >= left + 215 and mx <= left + 395 and
             my >= top - 27 and my <= top + 15)
    {
        play_select();
        active_tab = 2;
    }

    // HOW TO PLAY PAGE ARROWS
    else if (active_tab == 1)
    {
        if (mx >= left + 100 and mx <= left + 140 and
            my >= top + 235 and my <= top + 265)
        {
            play_select();
            help_page = max(1, help_page - 1);
        }
        else if (mx >= left + 280 and mx <= left + 320 and
                 my >= top + 235 and my <= top + 265)
        {
            play_select();
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

        // Only the teleport points can be clicked, and only once their area is discovered
        var tp = teleport_point_at(mx, my, image_x, map_y);

        if (tp != noone and area_is_discovered(tp.area_name)
            and instance_exists(obj_player))
        {
            play_select();
            obj_player.x = tp.x;
            obj_player.y = tp.y;

            help_open = false;
        }
    }
}
