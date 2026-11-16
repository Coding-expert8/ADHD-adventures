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

// Fish types, from common/slow/cheap to rare/fast/valuable.
// fish_weight is the spawn chance in percent (adds up to 100).
fish_points = [1, 2, 5, 10, 50];
fish_weight = [40, 28, 18, 11, 3];
fish_speed  = [1, 1.5, 2.5, 3.5, 6];
fish_sprite = [spr_fish_1, spr_fish_2, spr_fish_5, spr_fish_10, spr_fish_50];
// Depth band each type swims in (water surface is y 90, sand is y 342).
// Cheap fish stay near the surface, valuable ones near the bottom; bands overlap.
fish_y_min  = [105, 115, 160, 220, 265];
fish_y_max  = [200, 230, 285, 325, 330];
