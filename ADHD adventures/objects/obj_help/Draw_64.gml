var gw = display_get_gui_width();
var gh = display_get_gui_height();

// HELP button - top left
var button_x = 25;
var button_y = 20;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(make_color_rgb(105, 67, 38));
draw_roundrect(button_x, button_y, button_x + 110, button_y + 35, false);

draw_set_color(c_white);
draw_text(button_x + 55, button_y + 17, "HELP");

if (help_open)
{
    var board_w = 420;
    var board_h = 280;

    var left = (gw - board_w) / 2;
    var top = (gh - board_h) / 2;

    // Dark overlay
    draw_set_color(make_color_rgb(10, 25, 18));
    draw_set_alpha(0.75);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1);

    // Wooden board
    draw_set_color(make_color_rgb(112, 72, 42));
    draw_roundrect(left, top, left + board_w, top + board_h, false);

    // Inner panel
    draw_set_color(make_color_rgb(137, 91, 53));
    draw_roundrect(left + 10, top + 10, left + board_w - 10, top + board_h - 10, false);

    // Border
    draw_set_color(make_color_rgb(220, 180, 115));
    draw_rectangle(left + 18, top + 18, left + board_w - 18, top + board_h - 18, true);

    // Tabs
    var tab_y = top - 2;

    draw_set_color(active_tab == 1 ? make_color_rgb(137, 91, 53) : make_color_rgb(85, 53, 32));
    draw_roundrect(left + 25, tab_y - 25, left + 205, tab_y + 15, false);
    draw_rectangle(left + 25, tab_y, left + 205, tab_y + 15, false);

    draw_set_color(active_tab == 2 ? make_color_rgb(137, 91, 53) : make_color_rgb(85, 53, 32));
    draw_roundrect(left + 215, tab_y - 25, left + 395, tab_y + 15, false);
    draw_rectangle(left + 215, tab_y, left + 395, tab_y + 15, false);

    draw_set_color(c_white);
    draw_text(left + 115, tab_y - 5, "HOW TO PLAY");
    draw_text(left + 305, tab_y - 5, "TELEPORTATION");

    // Close X
    draw_set_color(make_color_rgb(120, 35, 30));
    draw_roundrect(left + board_w - 35, top + 10,
        left + board_w - 10, top + 35, false);

    draw_set_color(c_white);
    draw_text(left + board_w - 22, top + 22, "X");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // TAB 1: HOW TO PLAY
    if (active_tab == 1)
    {
        draw_set_color(make_color_rgb(255, 225, 165));

        // PAGE 1
        if (help_page == 1)
        {
            draw_text(left + 30, top + 65, "MOVEMENT & CONTROLS");

            draw_set_color(c_white);
            draw_text(left + 30, top + 110, "ARROW KEYS / WASD  -  Move");
            draw_text(left + 30, top + 150, "SHIFT  -  Sprint");
            draw_text(left + 30, top + 190, "Q  -  Talk to NPCs");
        }

        // PAGE 2
        else if (help_page == 2)
        {
            draw_text(left + 30, top + 65, "GAME PROGRESSION");

            draw_set_color(c_white);
            draw_text_ext(left + 30, top + 110,
                "Collect keys throughout your adventure to unlock the final boss.",
                22, 340);
        }

        // Navigation arrows
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_color(make_color_rgb(75, 55, 35));
        draw_roundrect(left + 100, top + 235, left + 140, top + 265, false);

        draw_set_color(c_white);
        draw_text(left + 120, top + 250, "<");

        draw_set_color(make_color_rgb(255, 225, 165));
        draw_text(gw / 2, top + 250, string(help_page) + " / 2");

        draw_set_color(make_color_rgb(75, 55, 35));
        draw_roundrect(left + 280, top + 235, left + 320, top + 265, false);

        draw_set_color(c_white);
        draw_text(left + 300, top + 250, ">");
    }

    // TAB 2: TELEPORTATION
    else if (active_tab == 2)
    {
        draw_set_color(make_color_rgb(255, 225, 165));
        draw_text(left + 30, top + 55, "TELEPORTATION GIMMICK");

        draw_set_color(c_white);
        draw_text_ext(left + 30, top + 95,
            "PLACEHOLDER: Add your teleportation instructions here.",
            18, 340);

        draw_set_color(make_color_rgb(255, 225, 165));
        draw_text(left + 30, top + 165, "YOUR TELEPORTATION CODE");

        draw_set_color(c_white);
        draw_text_ext(left + 30, top + 200,
            "PLACEHOLDER: Add your own teleportation mechanics here.",
            18, 340);
    }
}

// Reset drawing settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);