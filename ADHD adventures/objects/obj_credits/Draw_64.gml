var gw = display_get_gui_width();
var gh = display_get_gui_height();

// Credits button
var button_x = gw - 140;
var button_y = 20;

draw_set_color(make_color_rgb(105, 67, 38));
draw_roundrect(button_x, button_y, button_x + button_width, button_y + button_height, false);

draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(button_x + button_width / 2, button_y + button_height / 2, "CREDITS");

if (credits_open)
{
    var board_w = 420;
    var board_h = 340;

    // the board is laid out for a MENU_BOARD_HEIGHT px tall screen and scaled up to the real GUI
    var _s = menu_board_scale();
    gw /= _s;
    gh /= _s;
    matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _s, _s, 1));

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

    // Heading
	draw_set_font(Font7)
    draw_set_color(make_color_rgb(255, 225, 165));
    draw_text(gw / 2, top + 38, "GAME CREDITS");

    // Credits
	draw_set_font(fnt_default)
    draw_set_color(c_white);

    draw_text(gw / 2, top + 78, "Created by");
    draw_text(gw / 2, top + 101, "ADHD Adventures Development Team");

    draw_text(gw / 2, top + 145, "Special Thanks");
    draw_text(gw / 2, top + 168, "Ms Dam - Teacher");

    draw_text(gw / 2, top + 210, "Assets and Resources");
    draw_text(gw / 2, top + 233, "Kenney.nl");
    draw_text(gw / 2, top + 255, "OpenGameArt.org");
    draw_text(gw / 2, top + 277, "itch.io");

    draw_text(gw / 2, top + 305, "Inspired by Google Champion Island");

    // Close X
    draw_set_color(make_color_rgb(120, 35, 30));
    draw_roundrect(left + board_w - 38, top + 10, left + board_w - 12, top + 36, false);

    draw_set_color(c_white);
    draw_text(left + board_w - 25, top + 23, "X");
}

// Reset drawing settings
matrix_set(matrix_world, matrix_build_identity());
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);