// ======================================
// MESSAGE TIMER
// ======================================

if (shop_message_timer > 0)
{
    shop_message_timer--;

    if (shop_message_timer <= 0)
    {
        shop_message = "";
    }
}


// ======================================
// MOUSE COORDINATES
// ======================================

var gw = display_get_gui_width();
var gh = display_get_gui_height();

// Convert mouse GUI coordinates to our 642 x 358 layout
var mx = device_mouse_x_to_gui(0) * (642 / gw);
var my = device_mouse_y_to_gui(0) * (358 / gh);


// ======================================
// CLICK
// ======================================

if (mouse_check_button_pressed(mb_left))
{
    // BACK BUTTON
    if (point_in_rectangle(mx, my, 595, 20, 635, 65))
    {
        room_goto(room_map);
        exit;
    }


    // ==================================
    // CATEGORY TABS
    // ==================================

    if (point_in_rectangle(mx, my, 205, 80, 275, 110))
    {
        selected_category = 0;
        selected_item = 0;
    }
    else if (point_in_rectangle(mx, my, 275, 80, 340, 110))
    {
        selected_category = 1;
        selected_item = 0;
    }
    else if (point_in_rectangle(mx, my, 340, 80, 405, 110))
    {
        selected_category = 2;
        selected_item = 3;
    }
    else if (point_in_rectangle(mx, my, 405, 80, 500, 110))
    {
        selected_category = 3;
        selected_item = 5;
    }


    // ==================================
    // ITEM CARDS
    // ==================================

    var card_x = [255, 355, 455];
    var card_y = [170, 280];

    var visible_count = 0;

    for (var i = 0; i < 6; i++)
    {
        if (selected_category == 0 || item_category[i] == selected_category)
        {
            var col = visible_count mod 3;
            var row = floor(visible_count / 3);

            var cx = card_x[col];
            var cy = card_y[row];

            if (point_in_rectangle(
                mx,
                my,
                cx - 48,
                cy - 50,
                cx + 48,
                cy + 50
            ))
            {
                selected_item = i;
            }

            visible_count++;
        }
    }


    // ==================================
    // PURCHASE BUTTON
    // ==================================

    if (point_in_rectangle(mx, my, 520, 280, 620, 320))
    {
        var price = item_price[selected_item];
        var can_buy = true;


        // CHECK OWNERSHIP / HEALTH
        switch (selected_item)
        {
            case 0:
                if (global.has_fireball)
                    can_buy = false;
            break;

            case 1:
                if (global.has_lightning)
                    can_buy = false;
            break;

            case 2:
                if (global.has_ice)
                    can_buy = false;
            break;

            case 3:
                if (global.hearts >= 6)
                    can_buy = false;
            break;

            case 4:
                if (global.hearts >= 6)
                    can_buy = false;
            break;

            case 5:
                if (global.boss_speed_boost)
                    can_buy = false;
            break;
        }


        // PURCHASE
        if (!can_buy)
        {
            shop_message = "Already owned or cannot use!";
            shop_message_timer = 90;
        }
        else if (global.coin < price)
        {
            shop_message = "NOT ENOUGH COINS!";
            shop_message_timer = 90;
        }
        else
        {
            global.coin -= price;

            switch (selected_item)
            {
                case 0:
                    global.has_fireball = true;
                break;

                case 1:
                    global.has_lightning = true;
                break;

                case 2:
                    global.has_ice = true;
                break;

                case 3:
                    global.hearts = min(6, global.hearts + 1);
                break;

                case 4:
                    global.hearts = 6;
                break;

                case 5:
                    global.boss_speed_boost = true;
                break;
            }

            shop_message = "PURCHASE SUCCESSFUL!";
            shop_message_timer = 90;
        }
    }
}