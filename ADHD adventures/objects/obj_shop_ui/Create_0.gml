selected_item = 0;
selected_category = 0;

shop_message = "";
shop_message_timer = 0;

item_name = [
    "Fireball",
    "Lightning",
    "Ice Blast",
    "Extra Heart",
    "Full Heal",
    "Speed Boost"
];

item_description = [
    "Unlocks a ranged fire attack in boss fights.",
    "Unlocks a ranged lightning attack in boss fights.",
    "Unlocks a ranged ice attack in boss fights.",
    "Adds one half-heart to your health.",
    "Restores your health to maximum.",
    "Increases your speed during boss fights."
];

item_price = [100, 150, 200, 50, 120, 80];

item_category = [1, 1, 1, 2, 2, 3];

// Only initialise purchase flags if they don't already exist.
if (!variable_global_exists("has_fireball"))
    global.has_fireball = false;

if (!variable_global_exists("has_lightning"))
    global.has_lightning = false;

if (!variable_global_exists("has_ice"))
    global.has_ice = false;

if (!variable_global_exists("boss_speed_boost"))
    global.boss_speed_boost = false;