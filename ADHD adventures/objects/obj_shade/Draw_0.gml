// Nothing is drawn in the ordinary pass. The shade itself goes down in Draw End,
// after the day/night tint; this event exists to stop the 32x32 box sprite being
// drawn, while leaving the instance visible so that its Draw End still runs.
//
// Under F1 the box shows itself, so the regions can be seen and lined up.
if (!global.world_debug) exit;

draw_set_colour(c_navy);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
draw_set_colour(c_white);
