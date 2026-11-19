if (fade_alpha > 0) {
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();

    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_width, _gui_height, false);

    // Restore common drawing defaults for any later GUI drawing.
    draw_set_alpha(1);
    draw_set_color(c_white);
}