/// obj_sidequest_objective - DRAW

if (quest_id < 0 || quest_id >= 30) exit;
if (!global.sidequest_accepted[quest_id]) exit;
if (global.sidequest_complete[quest_id]) exit;

draw_set_color(c_yellow);
draw_circle(x, y, 10, false);
draw_set_color(c_white);