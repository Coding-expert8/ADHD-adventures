draw_self();

var bar_x = x - bar_w/2;
var bar_y = y - sprite_height/2 - 10;


draw_set_color(c_dkgray);
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);


var hp_ratio = hp / hp_max;
draw_set_color(c_red);
draw_rectangle(bar_x, bar_y, bar_x + bar_w * hp_ratio, bar_y + bar_h, false);
