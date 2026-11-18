// picked up: one more key towards the boss, one fewer waiting to be collected
global.key_count += 1;
global.keys_pending = max(0, global.keys_pending - 1);
save_game();
instance_destroy();
