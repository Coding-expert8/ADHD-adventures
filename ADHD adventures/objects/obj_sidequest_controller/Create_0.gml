
/// obj_sidequest_controller - CREATE

if (variable_global_exists("sidequest_ready")) exit;

global.sidequest_accepted = array_create(30, false);
global.sidequest_complete = array_create(30, false);
global.sidequest_paid = array_create(30, false);
global.sidequest_collect_count = array_create(30, 0);
global.sidequest_ready = true;

global.sidequest_types = array_create(30, "explore");

for (var i = 0; i < 10; i++)
    global.sidequest_types[i] = "explore";

for (var i = 10; i < 18; i++)
    global.sidequest_types[i] = "find_npc";

for (var i = 18; i < 26; i++)
    global.sidequest_types[i] = "landmark";

for (var i = 26; i < 30; i++)
    global.sidequest_types[i] = "collect";

// Keep the existing descriptions from your parent Create Event.
global.sidequest_npc_count = 30;
global.sidequest_objective_count = 30;

// Existing player and main-story NPC positions are protected.
global.sidequest_safe_margin = 160;

// Find collision tilemap.
global.sidequest_collision_map = layer_tilemap_get_id("Collision");

// Spawn positions are generated from walkable map tiles.
global.sidequest_spawn_positions = [];

var tile_size = 16;
var spacing = 320;

var npc_objects = [
    obj_side_npc_1,
    obj_side_npc_2,
    obj_side_npc_3,
    obj_side_npc_4,
    obj_side_npc_5,
    obj_side_npc_6
];

var player = instance_find(obj_player, 0);
var main_npc = instance_find(obj_npc, 0);

// Scan the map for possible NPC positions.
// Do not use arbitrary coordinates.
var candidates = [];

for (var yy = 256; yy < room_height - 256; yy += spacing)
{
    for (var xx = 256; xx < room_width - 256; xx += spacing)
    {
        var tile_data = tilemap_get_at_pixel(
            global.sidequest_collision_map,
            xx,
            yy
        );

        // Empty collision tile means walkable.
        if (tile_get_index(tile_data) != -1) continue;

        if (player != noone &&
            point_distance(xx, yy, player.x, player.y) < 600)
            continue;

        if (main_npc != noone &&
            point_distance(xx, yy, main_npc.x, main_npc.y) < 250)
            continue;

        array_push(candidates, [xx, yy]);
    }
}

// Shuffle candidates.
for (var i = array_length(candidates) - 1; i > 0; i--)
{
    var j = irandom(i);
    var temp = candidates[i];
    candidates[i] = candidates[j];
    candidates[j] = temp;
}

// Spawn 30 NPCs only if a candidate is sufficiently separated.
var spawned = 0;

for (var i = 0; i < array_length(candidates) && spawned < 30; i++)
{
    var sx = candidates[i][0];
    var sy = candidates[i][1];

    var safe = true;

    for (var j = 0; j < array_length(global.sidequest_spawn_positions); j++)
    {
        var pos = global.sidequest_spawn_positions[j];

        if (point_distance(sx, sy, pos[0], pos[1]) < 500)
        {
            safe = false;
            break;
        }
    }

    if (!safe) continue;

    // Do not spawn on existing instances.
    if (collision_circle(sx, sy, 48, obj_player, false, true))
        continue;

    if (collision_circle(sx, sy, 48, obj_npc, false, true))
        continue;

    array_push(global.sidequest_spawn_positions, [sx, sy]);

    var npc_type = npc_objects[spawned mod 6];

    var npc = instance_create_layer(
        sx,
        sy,
        "Instances",
        npc_type
    );

    npc.quest_id = spawned;
    npc.speaker = "Island Resident";
    npc.is_sidequest_npc = true;

    spawned++;
}

global.sidequest_spawned_npcs = spawned;

if (spawned < 30)
{
    show_debug_message(
        "Sidequests: only " + string(spawned) +
        " safe NPC positions found. No unsafe fallback used."
    );
}
