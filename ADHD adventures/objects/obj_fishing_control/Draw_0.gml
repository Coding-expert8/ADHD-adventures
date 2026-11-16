draw_set_font(global.fishing_font);
draw_set_colour(c_white);
draw_set_alpha(1);

// HUD
var _time = game_over ? time_taken : (current_time - start_time) / 1000;
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(10, 6, "Score: " + string(fish_score) + " / " + string(goal));
draw_text(10, 28, "Bait: " + string(bait));
draw_text(10, 50, "Fish: " + string(fish_caught));
draw_set_halign(fa_right);
draw_text(room_width - 10, 6, "Time: " + string_format(_time, 1, 1) + "s");
draw_text(room_width - 10, 28, "SPACE to cast");

// Results screen
if (game_over) {
    draw_set_alpha(0.7);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);

    var _cx = room_width / 2;
    var _cy = room_height / 2;
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_cx, _cy - 50, won ? "You win! Reached " + string(goal) + " points!" : "Out of bait!");
    draw_text(_cx, _cy - 20, "Total score: " + string(fish_score));
    draw_text(_cx, _cy + 2, "Fish caught: " + string(fish_caught));
    draw_text(_cx, _cy + 24, "Time taken: " + string_format(time_taken, 1, 1) + "s");
    draw_text(_cx, _cy + 56, "Press R to play again");
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
