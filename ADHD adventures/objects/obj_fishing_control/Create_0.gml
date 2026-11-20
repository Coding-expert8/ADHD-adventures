// Fishing minigame: tracks bait, score and time, spawns fish, draws the HUD.
depth = -100; // draw the HUD on top of the fish

bait = 25;
fish_score = 0;
fish_caught = 0;
goal = 100;

game_over = false;
won = false;
start_time = current_time; // reset when the intro closes, so the clock starts with the game
time_taken = 0;

// Intro: instructions and tips over the (already swimming) scene until SPACE or Q.
// "Play again" (R on the results screen) skips it, the player has just read it.
intro = not (variable_global_exists("fishing_skip_intro") and global.fishing_skip_intro);
global.fishing_skip_intro = false;

/// Draw text centred on x, shrunk (never stretched) so it is at most _max_w wide.
text_fit = function(_x, _y, _str, _scale, _max_w) {
    var _sc = min(_scale, _max_w / max(1, string_width(_str)));
    draw_text_transformed(_x, _y, _str, _sc, _sc, 0);
}

// Background music, looped until the game finishes (Step stops it and plays the win/lose sound)
music = audio_play_sound(mus_minigame_1, 10, true);

spawn_timer = 0;

// Clouds: a couple already in the sky, then a new one every 6-15 seconds
cloud_timer = irandom_range(360, 900);
repeat (irandom_range(1, 3)) {
    instance_create_layer(random_range(-60, room_width - 60), 0, "Instances", obj_fishing_cloud);
}

// Outlined text font, created once and shared (same approach as the NPC dialogue font).
// SDF + font effects draws the outline in one pass instead of redrawing the text around itself.
if (not variable_global_exists("fishing_font")) {
    global.fishing_font = font_add("supersoft.ttf", 30, false, false, 32, 127);
    font_enable_sdf(global.fishing_font, true);
    font_sdf_spread(global.fishing_font, 8);
    font_enable_effects(global.fishing_font, true, {
        outlineEnable: true,
        outlineDistance: 1,
        outlineColour: c_black,
    });
}

// Fish types, from common/slow/cheap to rare/fast/valuable, then trash last.
// fish_weight is the spawn chance in percent (adds up to 100).
// Trash takes 5 points away (score can't go below 0) and doesn't count as a fish.
TRASH = 5; // index of the trash type
fish_points = [1, 2, 5, 10, 50, -5];
fish_weight = [30, 26, 17, 15, 8, 4];
fish_speed  = [1, 2, 2.7, 3.5, 6, 0.8];
fish_sprite = [spr_fish_1, spr_fish_2, spr_fish_5, spr_fish_10, spr_fish_50, spr_fishing_trash];
// Depth band each type swims in (water surface is y 90, sand is y 342).
// Cheap fish stay near the surface, valuable ones near the bottom; bands overlap.
// Trash floats just under the surface.
fish_y_min  = [105, 115, 160, 220, 255, 105];
fish_y_max  = [220, 260, 285, 325, 330, 140];

heart_lost = false;