var gw = display_get_gui_width();
var gh = display_get_gui_height();

var sx = gw / 642;
var sy = gh / 358;
var u  = min(sx, sy); // uniform scale for sprites


// ======================================
// BACKGROUND
// ======================================

draw_sprite_ext(
    spr_shop_background,
    0,
    0,
    0,
    gw / sprite_get_width(spr_shop_background),
    gh / sprite_get_height(spr_shop_background),
    0,
    c_white,
    1
);


// ======================================
// TWEAKABLE LAYOUT VALUES (642x358 space)
// ======================================

// Item cards
var card_x = [256, 357, 459];
var card_y = [172, 281];
var card_name_dy   = -36;   // name, relative to card center
var card_icon_dy   = 0;     // icon, relative to card center
var card_price_dy  = 36;    // price / OWNED, relative to card center
var card_name_maxw = 86;    // max name/price width in design px
var card_icon_box  = 40;    // icon fit-box in design px

// Purchase panel
var panel_x        = 572;
var panel_name_y   = 118;
var panel_icon_y   = 155;
var panel_icon_box = 52;
var panel_desc_y   = 205;
var panel_desc_w   = 88;
var panel_text_s   = 0.8;   // text scale in panel

// Coin that is baked into the background art in the panel
var panel_coin_x   = 552;   // coin center X
var panel_coin_y   = 257;   // coin center Y
var panel_coin_gap = 14;    // gap from coin center to number


// ======================================
// COIN BALANCE (top right pill)
// ======================================

draw_set_font(Font6);
draw_set_color(c_white);
draw_set_halign(fa_right);
draw_set_valign(fa_middle);

draw_text(
    576 * sx,
    46 * sy,
    string(global.coin)
);


// ======================================
// DATA
// ======================================

var icons = [
    spr_shop_fireball_icon,
    spr_shop_lightning_icon,
    spr_shop_ice_icon,
    spr_shop_heart_icon,
    spr_shop_full_heal_icon,
    spr_shop_speed_icon
];

var short_description = [
    "Ranged fire attack.",
    "Ranged lightning attack.",
    "Ranged ice attack.",
    "Adds half a heart.",
    "Restores all health.",
    "Increases your speed."
];

var visible_count = 0;


// ======================================
// DRAW ITEM CARDS
// ======================================

for (var i = 0; i < 6; i++)
{
    if (selected_category == 0 || item_category[i] == selected_category)
    {
        var col = visible_count mod 3;
        var row = floor(visible_count / 3);

        var cx = card_x[col] * sx;
        var cy = card_y[row] * sy;

        draw_set_font(Font6);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);


        // ITEM NAME (auto-shrinks to fit the card)
        var nm = item_name[i];
        var ns = min(0.85, (card_name_maxw * sx) / max(1, string_width(nm)));

        draw_set_color(c_white);
        draw_text_transformed(
            cx,
            cy + card_name_dy * sy,
            nm,
            ns, ns, 0
        );


        // ITEM ICON (fit to box, centered regardless of sprite origin)
        var spr = icons[i];
        var s   = min((card_icon_box * u) / sprite_get_width(spr),
                      (card_icon_box * u) / sprite_get_height(spr));
        var ox  = (sprite_get_width(spr)  / 2 - sprite_get_xoffset(spr)) * s;
        var oy  = (sprite_get_height(spr) / 2 - sprite_get_yoffset(spr)) * s;

        draw_sprite_ext(
            spr, 0,
            cx - ox,
            cy + card_icon_dy * sy - oy,
            s, s, 0, c_white, 1
        );


        // OWNED STATUS
        var owned = false;

        switch (i)
        {
            case 0: owned = global.has_fireball; break;
            case 1: owned = global.has_lightning; break;
            case 2: owned = global.has_ice; break;
            case 5: owned = global.boss_speed_boost; break;
        }


        // PRICE (or OWNED in its place)
        if (owned)
        {
            draw_set_color(c_lime);
            draw_text(cx, cy + card_price_dy * sy, "OWNED");
        }
        else
        {
            var price_str = string(item_price[i]) + " coins";

            // shrink only if it's too wide for the card
            var ps = min(1, (card_name_maxw * sx) / max(1, string_width(price_str)));

            draw_set_color(c_white);
            draw_text_transformed(
                cx,
                cy + card_price_dy * sy,
                price_str,
                ps, ps, 0
            );
        }

        visible_count++;
    }
}


// ======================================
// PURCHASE PANEL
// ======================================

draw_set_font(Font6);
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var px = panel_x * sx;


// ITEM NAME
draw_text_transformed(
    px,
    panel_name_y * sy,
    item_name[selected_item],
    panel_text_s, panel_text_s, 0
);


// ITEM ICON
var sspr = icons[selected_item];
var ss   = min((panel_icon_box * u) / sprite_get_width(sspr),
               (panel_icon_box * u) / sprite_get_height(sspr));
var sox  = (sprite_get_width(sspr)  / 2 - sprite_get_xoffset(sspr)) * ss;
var soy  = (sprite_get_height(sspr) / 2 - sprite_get_yoffset(sspr)) * ss;

draw_sprite_ext(
    sspr, 0,
    px - sox,
    panel_icon_y * sy - soy,
    ss, ss, 0, c_white, 1
);


// SHORT DESCRIPTION (auto line height, wraps inside the panel)
draw_text_ext_transformed(
    px,
    panel_desc_y * sy,
    short_description[selected_item],
    -1,
    (panel_desc_w * sx) / panel_text_s,
    panel_text_s, panel_text_s, 0
);


// PRICE: coin symbol (baked into the background) then the number only
draw_set_halign(fa_left);
draw_set_color(c_black);
draw_text(
    (panel_coin_x + panel_coin_gap) * sx,
    panel_coin_y * sy,
    string(item_price[selected_item])
);


// BUY
draw_set_halign(fa_center);
draw_text(
    px,
    300 * sy,
    "BUY"
);


// ======================================
// PENGUIN SPEECH (centered in the bubble)
// ======================================

draw_set_font(Font6);
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_text_ext_transformed(
    134 * sx,
    142 * sy,
    "Welcome to the Island Shop!",
    -1,
    (84 * sx) / 0.85,
    0.85, 0.85, 0
);


// ======================================
// PURCHASE MESSAGE
// ======================================

if (shop_message != "")
{
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_text(
        320 * sx,
        340 * sy,
        shop_message
    );
}


// ======================================
// RESET DRAW SETTINGS
// ======================================

draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);