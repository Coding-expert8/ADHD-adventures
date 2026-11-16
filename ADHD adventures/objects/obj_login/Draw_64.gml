if (popup_open)
{
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();

    var scale = 0.7;

    var board_w = 540 * scale;
    var board_h = 350 * scale;

    var left = (gw - board_w) / 2;
    var top = (gh - board_h) / 2;

    // Outer green border
    draw_set_color(make_color_rgb(38, 59, 40));
    draw_roundrect(left - 7, top - 7,
        left + board_w + 7, top + board_h + 7, false);

    // Wooden board
    draw_set_color(make_color_rgb(121, 87, 55));
    draw_roundrect(left, top,
        left + board_w, top + board_h, false);

    // Wooden outline
    draw_set_color(make_color_rgb(75, 46, 28));
    draw_roundrect(left, top,
        left + board_w, top + board_h, true);

    // Title
    draw_set_color(make_color_rgb(245, 227, 189));
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_text_transformed(left + 270 * scale, top + 42 * scale,
        "ADHD ADVENTURES", scale, scale, 0);

    // Divider
    draw_set_color(make_color_rgb(177, 138, 87));
    draw_line(left + 20 * scale, top + 92 * scale,
        left + 520 * scale, top + 92 * scale);

    // Question
    draw_set_color(make_color_rgb(245, 227, 189));
    draw_text_transformed(left + 270 * scale, top + 145 * scale,
        "What is your name?", scale, scale, 0);

    // Username box
    draw_set_color(make_color_rgb(232, 213, 173));
    draw_roundrect(left + 20 * scale, top + 183 * scale,
        left + 520 * scale, top + 247 * scale, false);

    // Username
    draw_set_halign(fa_left);
    draw_set_color(make_color_rgb(96, 71, 44));

    if (username_input == "")
    {
        draw_text_transformed(left + 32 * scale, top + 215 * scale,
            "Enter username...", scale, scale, 0);
    }
    else
    {
        draw_text_transformed(left + 32 * scale, top + 215 * scale,
            username_input, scale, scale, 0);
    }

    // SAVE button
    draw_set_color(make_color_rgb(69, 99, 59));
    draw_roundrect(left + 20 * scale, top + 263 * scale,
        left + 520 * scale, top + 327 * scale, false);

    draw_set_halign(fa_center);
    draw_set_color(c_white);

    draw_text_transformed(left + 270 * scale, top + 295 * scale,
        "SAVE", scale, scale, 0);

    // Close button
    draw_set_color(make_color_rgb(75, 46, 28));
    draw_roundrect(left + 485 * scale, top + 12 * scale,
        left + 525 * scale, top + 52 * scale, false);

    draw_set_color(c_white);
    draw_text_transformed(left + 505 * scale, top + 32 * scale,
        "X", scale, scale, 0);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}