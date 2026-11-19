var bar_width = 400;
var bar_height = 20;

var bar_x = (display_get_gui_width() - bar_width) / 2;
var bar_y = 35;

// Background
draw_set_color(c_black);

draw_rectangle(
    bar_x - 2,
    bar_y - 2,
    bar_x + bar_width + 2,
    bar_y + bar_height + 2,
    false
);

// Health bar
draw_set_color(c_red);

draw_rectangle(
    bar_x,
    bar_y,
    bar_x + bar_width * (health / max_health),
    bar_y + bar_height,
    false
);

// Boss name
draw_set_color(c_white);
draw_set_font(Font6)
draw_text(
    bar_x,
    bar_y - 22,
    "CORRUPTED GUARDIAN"
);