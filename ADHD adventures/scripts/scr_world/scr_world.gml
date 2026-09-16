// World systems shared by obj_world, obj_terrain and anything that walks around the map.

#macro YSORT_MARGIN_X 200     // sprites stick out sideways past their footprint mask...
#macro YSORT_MARGIN_DOWN 400  // ...and upwards, so look below the view for their bases too

global.world_debug = false;   // toggled with F1 by obj_world
global.tm_collision = -1;     // tilemap of the "Collision" layer, set by obj_world
global.tm_terrain = -1;       // tilemap of the "Terrain" layer, set by obj_world

/// @func world_view_rect()
/// @desc Returns [x, y, width, height] of the area being drawn.
function world_view_rect() {
    if (view_enabled) {
        var _cam = view_camera[0];
        return [camera_get_view_x(_cam), camera_get_view_y(_cam), camera_get_view_width(_cam), camera_get_view_height(_cam)];
    }
    return [0, 0, room_width, room_height];
}

/// @func world_blocked(x, y)
/// @desc True if the calling instance's collision mask would touch something solid at (x, y):
///       a painted Collision tile, a prop footprint or a solid terrain cell such as water.
function world_blocked(_x, _y) {
    if (global.tm_collision != -1 and place_meeting(_x, _y, global.tm_collision)) return true;
    if (place_meeting(_x, _y, obj_prop)) return true;

    var _dx = _x - x;
    var _dy = _y - y;
    return terrain_solid_at(bbox_left + _dx, bbox_top + _dy)
        or terrain_solid_at(bbox_right + _dx, bbox_top + _dy)
        or terrain_solid_at(bbox_left + _dx, bbox_bottom + _dy)
        or terrain_solid_at(bbox_right + _dx, bbox_bottom + _dy);
}
