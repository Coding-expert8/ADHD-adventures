if (menu_open)
{
    // GUI dimensions
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    // Menu positioning
    var _mx = (_gw - menu_width) / 2;
    var _my = (_gh - menu_height) / 2;

    // Mouse GUI position
    var _mouse_x = device_mouse_x_to_gui(0);
    var _mouse_y = device_mouse_y_to_gui(0);

    // Close with ESC
    if (keyboard_check_pressed(vk_escape))
    {
        menu_open = false;
    }

    // Close button
    var _close_x = _mx + menu_width - 40;
    var _close_y = _my + 60;

    if (mouse_check_button_pressed(mb_left))
    {
        if (point_in_rectangle(
            _mouse_x, _mouse_y,
            _close_x - 15, _close_y - 15,
            _close_x + 15, _close_y + 15
        ))
        {
            menu_open = false;
        }
    }

    // ITEM GRID SETTINGS
    var _padding = 20;
    var _gap = 12;

    var _slot_w = (menu_width - _padding * 2 - _gap * 2) / 3;
    var _slot_h = 145;

    var _grid_x = _mx + _padding;
    var _grid_y = _my + 90;

    // Check item purchases
    if (mouse_check_button_pressed(mb_left) && menu_open)
    {
        for (var i = 0; i < 6; i++)
        {
            var _col = i mod 3;
            var _row = floor(i / 3);

            var _sx = _grid_x + _col * (_slot_w + _gap);
            var _sy = _grid_y + _row * (_slot_h + _gap);

            var _item = shop_items[i];

            // Check if slot was clicked
            if (point_in_rectangle(
                _mouse_x, _mouse_y,
                _sx, _sy,
                _sx + _slot_w,
                _sy + _slot_h
            ))
            {
                // Make sure item exists and is affordable
                if (_item.name != "" && _item.price > 0)
                {
                    if (global.coin >= _item.price)
                    {
                        // Deduct currency
                        global.coin -= _item.price;

                        // PURCHASE SUCCESSFUL
                        show_debug_message(
                            "Purchased: " + _item.name
                        );

                        // ADD ITEM GRANTING CODE HERE
                    }
                }
            }
        }
    }
}