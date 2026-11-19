/// obj_sidequest_objective - STEP

if (quest_id < 0 || quest_id >= 30) exit;
if (!global.sidequest_accepted[quest_id]) exit;
if (global.sidequest_complete[quest_id]) exit;

var p = instance_find(obj_player, 0);
if (p == noone) exit;

var distance = point_distance(x, y, p.x, p.y);

switch (objective_type)
{
    case "explore":
        if (distance < 80)
            global.sidequest_complete[quest_id] = true;
    break;

    case "find_npc":
        var target = instance_find(obj_npc, 0);

        if (target != noone &&
            distance_to_object(target) < 100)
            global.sidequest_complete[quest_id] = true;
    break;

    case "landmark":
        if (distance < 80)
            global.sidequest_complete[quest_id] = true;
    break;

    case "collect":
        if (distance < 45)
        {
            global.sidequest_collect_count[quest_id]++;

            if (global.sidequest_collect_count[quest_id] >= 3)
                global.sidequest_complete[quest_id] = true;

            x = -10000;
            y = -10000;
        }
    break;
}