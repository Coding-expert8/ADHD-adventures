// ==============================
// SIDE QUEST NPC - CREATE
// ==============================

// Quest assignment (set individually in Instance Creation Code)
quest_id = 0;

quest_title = "Side Quest";
quest_description = "Help me with something.";

target_x = x;
target_y = y;
target_radius = 24;

// NPC settings
speaker = "NPC";
talk_range = 24;
text_speed = 1;

// Dialogue
dialogue = [];
line = 0;
shown = 0;

// Shared dialogue system
if (!variable_global_exists("dialogue_npc"))
{
    global.dialogue_npc = noone;
}

// Quest tracking arrays - 30 quests
if (!variable_global_exists("sidequest_accepted"))
{
    global.sidequest_accepted = array_create(30, false);
}

if (!variable_global_exists("sidequest_complete"))
{
    global.sidequest_complete = array_create(30, false);
}

if (!variable_global_exists("sidequest_paid"))
{
    global.sidequest_paid = array_create(30, false);
}

// Existing dialogue font from your project
if (!variable_global_exists("dialogue_font"))
{
    global.dialogue_font = font_add(
        "supersoft.ttf",
        30,
        false,
        false,
        32,
        127
    );

    font_enable_sdf(global.dialogue_font, true);
    font_sdf_spread(global.dialogue_font, 8);

    font_enable_effects(global.dialogue_font, true, {
        outlineEnable: true,
        outlineDistance: 2,
        outlineColour: c_black
    });
}

// Existing dialogue text font
if (!variable_global_exists("dialogue_text_font"))
{
    global.dialogue_text_font = font_add(
        "supersoft.ttf",
        42,
        false,
        false,
        32,
        127
    );

    font_enable_sdf(global.dialogue_text_font, true);
    font_sdf_spread(global.dialogue_text_font, 8);

    font_enable_effects(global.dialogue_text_font, true, {
        outlineEnable: true,
        outlineDistance: 2,
        outlineColour: c_black
    });
}