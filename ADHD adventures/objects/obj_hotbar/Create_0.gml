// HOTBAR SETTINGS
selected_slot = 1;

hotbar_slots = 6;

slot_size = 64;
slot_gap = 8;

hotbar_margin_bottom = 25;


// =====================================
// HOTBAR ITEMS
// =====================================

hotbar_items = [

    // SLOT 1 - BRAKE
    {
        sprite: spr_brake,
        cooldown: 5,
        cooldown_remaining: 0
    },

    // SLOT 2
    {
        sprite: spr_blaster_space_rocks,
        cooldown: 0,
        cooldown_remaining: 0
    },

    // SLOT 3
    {
        sprite: spr_machine_gun,
        cooldown: 10,
        cooldown_remaining: 0
    },

    // SLOT 4
    {
        sprite: spr_booster_space_rocks,
        cooldown: 7,
        cooldown_remaining: 0
    },

    // SLOT 5
    {
        sprite: spr_compass,
        cooldown: 5,
        cooldown_remaining: 0
    },

    // SLOT 6
    {
        sprite: spr_map_space_rocks,
        cooldown: 0,
        cooldown_remaining: 0
    }
];


// COMPASS SETTINGS
compass_arrow_length = 300;
compass_arrow_active = false;

// MAP SETTINGS
map_open = false;