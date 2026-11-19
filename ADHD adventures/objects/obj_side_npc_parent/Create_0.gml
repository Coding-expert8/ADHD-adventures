/// obj_side_npc_parent - CREATE

// --------------------------------------------------
// INDIVIDUAL NPC DEFAULTS
// --------------------------------------------------

quest_id = 0;
speaker = "Villager";

talk_range = 48;
text_speed = 1;

dialogue = ["Hello!"];
line = 0;
shown = 0;

// --------------------------------------------------
// SHARED QUEST DATA
// --------------------------------------------------

if (!variable_global_exists("sidequest_accepted"))
{
    global.sidequest_accepted = array_create(30, false);
    global.sidequest_complete = array_create(30, false);
    global.sidequest_paid = array_create(30, false);
    global.sidequest_collect_count = array_create(30, 0);
}

// Shared dialogue
if (!variable_global_exists("dialogue_npc"))
    global.dialogue_npc = noone;

// Coins
if (!variable_global_exists("coins"))
    global.coins = 0;

// Existing font
if (!variable_global_exists("dialogue_font"))
    global.dialogue_font = font_add("VT323-Regular.ttf", 24, false, false, 32, 255);

// --------------------------------------------------
// CENTRAL QUEST DATABASE
// --------------------------------------------------

if (!variable_global_exists("sidequest_types"))
{
    global.sidequest_types = array_create(30, "explore");

    // 0-9: Exploration
    for (var i = 0; i < 10; i++)
        global.sidequest_types[i] = "explore";

    // 10-17: Find another NPC
    for (var i = 10; i < 18; i++)
        global.sidequest_types[i] = "find_npc";

    // 18-25: Interact with a landmark
    for (var i = 18; i < 26; i++)
        global.sidequest_types[i] = "landmark";

    // 26-29: Collect three items
    for (var i = 26; i < 30; i++)
        global.sidequest_types[i] = "collect";

    global.sidequest_descriptions = [
        "Could you explore the area and see what you can find?",
        "Could you visit somewhere new and tell me what you discover?",
        "Could you take a look around the island for me?",
        "Could you explore the forest and report back?",
        "Could you visit the lake and see how things are going?",
        "Could you take a walk through the town for me?",
        "Could you explore the nearby paths?",
        "Could you visit the higher parts of the island?",
        "Could you explore the village surroundings?",
        "Could you visit another part of the island?",

        "Could you find someone I need to speak to?",
        "Could you look for a traveller around the island?",
        "Could you find the person who knows about the forest?",
        "Could you find someone near the water?",
        "Could you locate a villager who can help me?",
        "Could you find the person I mentioned?",
        "Could you look for someone around the town?",
        "Could you find the islander I am looking for?",

        "Could you inspect this landmark for me?",
        "Could you take a closer look at an old structure?",
        "Could you visit the nearby notice board?",
        "Could you inspect the area around the lake?",
        "Could you check the old sign for me?",
        "Could you visit the nearby gathering place?",
        "Could you inspect the landmark in the forest?",
        "Could you take a look at the structure nearby?",

        "Could you collect three items for me?",
        "Could you gather three useful things?",
        "Could you find three things that I need?",
        "Could you collect three items from around the island?"
    ];
}

// --------------------------------------------------
// NPC APPEARANCE
// --------------------------------------------------

image_xscale = 0.4;
image_yscale = 0.4;
// Sidequest NPC identification
is_sidequest_npc = true;
quest_id = -1;
speaker = "Villager";
talk_range = 48;