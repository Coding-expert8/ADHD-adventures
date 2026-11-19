
/// obj_side_npc_parent - STEP

if (!variable_global_exists("sidequest_ready")) exit;
if (quest_id < 0 || quest_id >= 30) exit;
var p = instance_find(obj_player, 0);
if (p == noone) exit;

// Only the NPC currently speaking can process dialogue input.
var talking = (global.dialogue_npc == id);

if (talking)
{
    shown = min(shown + text_speed, string_length(dialogue[line]));

    if (keyboard_check_pressed(ord("Q")) ||
        keyboard_check_pressed(ord("E")))
    {
        if (shown < string_length(dialogue[line]))
        {
            shown = string_length(dialogue[line]);
        }
        else if (line < array_length(dialogue) - 1)
        {
            line++;
            shown = 0;
        }
        else
        {
            global.dialogue_npc = noone;
        }

        keyboard_clear(ord("Q"));
        keyboard_clear(ord("E"));
    }

    exit;
}

// Never open a second dialogue while one is active.
if (global.dialogue_npc != noone) exit;

// Interaction must be pressed while close to this NPC.
if (!keyboard_check_pressed(ord("Q")) &&
    !keyboard_check_pressed(ord("E"))) exit;

if (point_distance(x, y, p.x, p.y) > talk_range) exit;

var q = quest_id;

if (global.sidequest_paid[q])
{
    dialogue = ["Thanks again for helping me!"];
}
else if (global.sidequest_complete[q])
{
    // Pay only once.
    global.coins += 5;
    global.sidequest_paid[q] = true;

    dialogue = [
        "Thank you so much!",
        "Here are your 5 coins."
    ];
}
else if (!global.sidequest_accepted[q])
{
    global.sidequest_accepted[q] = true;

    dialogue = [
        "Could you help me with something?",
        global.sidequest_descriptions[q],
        "Come back when you have finished!",
        "I'll give you 5 coins."
    ];
}
else
{
    dialogue = [
        "Have you finished what I asked?",
        "Please come back when you have."
    ];
}

global.dialogue_npc = id;
line = 0;
shown = 0;

keyboard_clear(ord("Q"));
keyboard_clear(ord("E"));
