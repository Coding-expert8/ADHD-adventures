if (menu_open)
{
    // GUI dimensions
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    // Menu positioning
    var _mx = (_gw - menu_width) / 2;
    var _my = (_gh - menu_height) / 2;

    // =================================
    // DARKEN BACKGROUND
    // =================================

    draw_set_alpha(0.65);
    draw_set_color(c_black);

    draw_rectangle(0, 0, _gw, _gh, false);

    draw_set_alpha(1);

    // =================================
    // MAIN MENU BACKGROUND
    // =================================

    draw_set_color(make_color_rgb(35, 30, 30));

    draw_rectangle(
        _mx, _my,
        _mx + menu_width,
        _my + menu_height,
        false
    );

    // Menu border
    draw_set_color(make_color_rgb(220, 100, 35));

    draw_rectangle(
        _mx, _my,
        _mx + menu_width,
        _my + menu_height,
        true
    );

    // =================================
    // TITLE
    // =================================

    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);

    draw_text(
        _mx + 20,
        _my + 30,
        "ITEM SHOP"
    );

    // =================================
    // COIN DISPLAY
    // =================================

    draw_set_color(make_color_rgb(255, 190, 40));

    draw_text(
        _mx + 20,
        _my + 65,
        "Coins: " + string(global.coin)
    );

    // =================================
    // CLOSE BUTTON
    // =================================

    var _close_x = _mx + menu_width - 40;
    var _close_y = _my + 25;

    draw_set_color(make_color_rgb(170, 45, 35));

    draw_rectangle(
        _close_x - 15,
        _close_y - 15,
        _close_x + 15,
        _close_y + 15,
        false
    );

    draw_set_color(c_white);

    draw_text(
        _close_x - 5,
        _close_y - 10,
        "X"
    );

    // =================================
    // ITEM GRID
    // =================================

    var _padding = 20;
    var _gap = 12;

    var _slot_w = (menu_width - _padding * 2 - _gap * 2) / 3;
    var _slot_h = 145;

    var _grid_x = _mx + _padding;
    var _grid_y = _my + 90;

    for (var i = 0; i < 6; i++)
    {
        var _col = i mod 3;
        var _row = floor(i / 3);

        var _sx = _grid_x + _col * (_slot_w + _gap);
        var _sy = _grid_y + _row * (_slot_h + _gap);

        var _item = shop_items[i];

        // Slot background
        draw_set_color(make_color_rgb(55, 48, 45));

        draw_rectangle(
            _sx, _sy,
            _sx + _slot_w,
            _sy + _slot_h,
            false
        );

        // Slot border
        draw_set_color(make_color_rgb(120, 90, 75));

        draw_rectangle(
            _sx, _sy,
            _sx + _slot_w,
            _sy + _slot_h,
            true
        );

        // Item sprite
        if (_item.sprite != -1)
        {
            draw_sprite_ext(
                _item.sprite,
                0,
                _sx + _slot_w / 2,
                _sy + 35,
                1, 1, 0,
                c_white, 1
            );
        }

        // Item name
        draw_set_color(c_white);

        draw_text(
            _sx + 8,
            _sy + 65,
            _item.name
        );

        // Item description
        draw_set_color(make_color_rgb(190, 190, 190));

        draw_text(
            _sx + 8,
            _sy + 85,
            _item.description
        );

        // Item price
        draw_set_color(make_color_rgb(255, 195, 50));

        var _price_text = "Price: ";

        if (_item.price > 0)
        {
            _price_text += string(_item.price);
        }
        else
        {
            _price_text += "---";
        }

        draw_text(
            _sx + 8,
            _sy + 115,
            _price_text
        );
    }

    // =================================
    // RESET DRAW SETTINGS
    // =================================

    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}