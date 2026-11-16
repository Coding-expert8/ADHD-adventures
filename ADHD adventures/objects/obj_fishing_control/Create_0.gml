// Fishing minigame: tracks bait, score and time, spawns fish, draws the HUD.
depth = -100; // draw the HUD on top of the fish

bait = 20;
fish_score = 0;
fish_caught = 0;
goal = 100;

game_over = false;
won = false;
start_time = current_time;
time_taken = 0;

spawn_timer = 0;

// Clouds: a couple already in the sky, then a new one every 6-15 seconds
cloud_timer = irandom_range(360, 900);
repeat (irandom_range(1, 3)) {
    instance_create_layer(random_range(-60, room_width - 60), 0, "Instances", obj_fishing_cloud);
}

// Outlined text font, created once and shared (same approach as the NPC dialogue font).
// SDF + font effects draws the outline in one pass instead of redrawing the text around itself.
if (not variable_global_exists("fishing_font")) {
    global.fishing_font = font_add("supersoft.ttf", 16, false, false, 32, 127);
    font_enable_sdf(global.fishing_font, true);
    font_sdf_spread(global.fishing_font, 8);
    font_enable_effects(global.fishing_font, true, {
        outlineEnable: true,
        outlineDistance: 2,
        outlineColour: c_black,
    });
}

// Fish types, from common/slow/cheap to rare/fast/valuable.
// fish_weight is the spawn chance in percent (adds up to 100).
fish_points = [1, 2, 5, 10, 50];
fish_weight = [34, 26, 20, 14, 6];
fish_speed  = [1, 1.5, 2.5, 3.5, 6];
fish_sprite = [spr_fish_1, spr_fish_2, spr_fish_5, spr_fish_10, spr_fish_50];
// Depth band each type swims in (water surface is y 90, sand is y 342).
// Cheap fish stay near the surface, valuable ones near the bottom; bands overlap.
fish_y_min  = [105, 115, 160, 220, 265];
fish_y_max  = [200, 230, 285, 325, 330];
