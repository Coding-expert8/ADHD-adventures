// Called by obj_world when it is the player's turn in the Y-sort (see par_ysort).
draw_self();

if (room == Room3)
{
    var bar_width = 24;
    var bar_height = 3;

    var bar_x = x - bar_width / 2;
    var bar_y = y - 32;

    var pp = clamp(hp / max_health, 0, 1);

    // Background
    draw_set_color(c_black);
    draw_rectangle(bar_x - 1, bar_y - 1,
                   bar_x + bar_width + 1, bar_y + bar_height + 1, false);

    // Health remaining
    draw_set_color(c_red);
    draw_rectangle(bar_x, bar_y,
                   bar_x + bar_width, bar_y + bar_height, false);

    draw_set_color(c_lime);
    draw_rectangle(bar_x, bar_y,
                   bar_x + bar_width * pp, bar_y + bar_height, false);

    draw_set_color(c_white);
}