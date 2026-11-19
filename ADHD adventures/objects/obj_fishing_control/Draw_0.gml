draw_set_font(global.fishing_font);
draw_set_colour(c_white);
draw_set_alpha(1);

// HUD
var _time = game_over ? time_taken : (intro ? 0 : (current_time - start_time) / 1000);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(10, 6, "Score: " + string(fish_score) + " / " + string(goal));
draw_text(10, 28, "Bait: " + string(bait));
draw_text(10, 50, "Fish: " + string(fish_caught));
draw_set_halign(fa_right);
draw_text(room_width - 10, 6, "Time: " + string_format(_time, 1, 1) + "s");
draw_text(room_width - 10, 28, "SPACE to cast");

// Intro: how to play, what each catch is worth, and tips
if (intro) {
    var _cx = room_width / 2;
    var _w = room_width - 80; // widest a line may be
    var _col_head = make_color_rgb(120, 210, 255);
    var _col_gold = make_color_rgb(255, 215, 90);
    var _col_bad  = make_color_rgb(255, 110, 100);

    draw_set_alpha(0.75);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(0.9);
    draw_set_colour(make_color_rgb(14, 40, 70));
    draw_roundrect(24, 12, room_width - 24, room_height - 12, false);
    draw_set_alpha(1);
    draw_set_colour(_col_head);
    draw_roundrect(24, 12, room_width - 24, room_height - 12, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // title
    draw_set_colour(c_white);
    text_fit(_cx, 34, "FISHING", 1.3, _w);

    // how to play
    draw_set_colour(_col_head);
    text_fit(_cx, 66, "HOW TO PLAY", 0.8, _w);
    draw_set_colour(c_white);
    text_fit(_cx, 86,  "Press SPACE to drop your hook straight down", 0.65, _w);
    text_fit(_cx, 104, "Every cast uses 1 bait, you start with" + string(bait), 0.65, _w);
    text_fit(_cx, 122, "Score " + string(goal) + " points before your bait runs out to win a key", 0.65, _w);

    // what's in the water: each sprite with its points under it
    draw_set_colour(_col_head);
    var _n = array_length(fish_sprite);
    var _slot = _w / _n;
    for (var _i = 0; _i < _n; _i++) {
        var _sx = 40 + _slot * (_i + 0.5);
        draw_sprite(fish_sprite[_i], 0, _sx, 178);
        var _p = fish_points[_i];
        draw_set_colour(_p < 0 ? _col_bad : _col_gold);
        text_fit(_sx, 202, (_p > 0 ? "+" : "") + string(_p), 0.7, _slot - 8);
    }

    // tips
    draw_set_colour(_col_head);
    text_fit(_cx, 230, "TIPS", 0.8, _w);
    draw_set_colour(c_white);
    text_fit(_cx, 250, "Rare fish swim deeper and faster, so drop early", 0.65, _w);
    text_fit(_cx, 270, "A miss still costs bait, so wait for a good shot", 0.65, _w);

    // start prompt, bobbing
    draw_set_colour(_col_gold);
    text_fit(_cx, 322 + sin(current_time / 200) * 2, "Press SPACE to start", 0.9, _w);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    exit;
}

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
    draw_text(_cx, _cy + 56, won ? "Q - back to map" : "R - play again     Q - back to map");
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
