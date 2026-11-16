if (popup_open)
{
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();

    var board_w = 540;
    var board_h = 350;

    var left = (gw - board_w) / 2;
    var top = (gh - board_h) / 2;

    // Dark green outer border
    draw_set_color(make_color_rgb(38, 59, 40));
    draw_roundrect(
        left - 10, top - 10,
        left + board_w + 10, top + board_h + 10,
        false
    );

    // Wooden board
    draw_set_color(make_color_rgb(121, 87, 55));
    draw_roundrect(
        left, top,
        left + board_w, top + board_h,
        false
    );

    // Dark wooden outline
    draw_set_color(make_color_rgb(75, 46, 28));
    draw_roundrect(
        left, top,
        left + board_w, top + board_h,
        true
    );

    // Title
    draw_set_color(make_color_rgb(245, 227, 189));
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_text(
        left + board_w / 2,
        top + 42,
        "ADHD ADVENTURES"
    );

    // Divider
    draw_set_color(make_color_rgb(177, 138, 87));
    draw_line(
        left + 20, top + 92,
        left + board_w - 20, top + 92
    );

    // Question
    draw_set_color(make_color_rgb(245, 227, 189));

    draw_text(
        left + board_w / 2,
        top + 145,
        "What is your name?"
    );

    // Username box
    draw_set_color(make_color_rgb(232, 213, 173));

    draw_roundrect(
        left + 20, top + 183,
        left + board_w - 20, top + 247,
        false
    );

    // Username text
    draw_set_halign(fa_left);
    draw_set_color(make_color_rgb(96, 71, 44));

    if (username_input == "")
    {
        draw_text(left + 32, top + 215, "Enter username...");
    }
    else
    {
        draw_text(left + 32, top + 215, username_input);
    }

    // SAVE button
    draw_set_color(make_color_rgb(69, 99, 59));

    draw_roundrect(
        left + 20, top + 263,
        left + board_w - 20, top + 327,
        false
    );

    draw_set_halign(fa_center);
    draw_set_color(c_white);

    draw_text(
        left + board_w / 2,
        top + 295,
        "SAVE"
    );

    // Close button
    draw_set_color(make_color_rgb(75, 46, 28));

    draw_roundrect(
        left + 485, top + 12,
        left + 525, top + 52,
        false
    );

    draw_set_color(c_white);
    draw_text(left + 505, top + 32, "X");

    // Reset drawing settings
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}