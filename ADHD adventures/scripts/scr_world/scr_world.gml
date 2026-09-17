// World systems shared by obj_world, obj_terrain and anything that walks around the map.

#macro YSORT_MARGIN_X 200     // sprites stick out sideways past their footprint mask...
#macro YSORT_MARGIN_DOWN 400  // ...and upwards, so look below the view for their bases too
#macro COLLISION_CELL 16      // tile size of the "Collision" layer (shapes in scr_collision_data)

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

/// @func collision_tile_at(x, y)
/// @desc Index of the Collision tile under a room position (0 = none).
function collision_tile_at(_px, _py) {
    if (global.tm_collision == -1) return 0;
    var _data = tilemap_get_at_pixel(global.tm_collision, _px, _py);
    return (_data == -1) ? 0 : tile_get_index(_data);
}

/// @func collision_rect_solid(left, top, right, bottom)
/// @desc True if a solid pixel of a Collision tile shape lies inside the rectangle (inclusive room
///       coordinates). Mirrored and flipped tiles work; rotated ones are treated as unrotated.
function collision_rect_solid(_l, _t, _r, _b) {
    var _tm = global.tm_collision;
    if (_tm == -1) return false;
    _l = floor(_l);
    _t = floor(_t);
    _r = floor(_r);
    _b = floor(_b);
    var _cx0 = max(floor(_l / COLLISION_CELL), 0);
    var _cy0 = max(floor(_t / COLLISION_CELL), 0);
    var _cx1 = min(floor(_r / COLLISION_CELL), tilemap_get_width(_tm) - 1);
    var _cy1 = min(floor(_b / COLLISION_CELL), tilemap_get_height(_tm) - 1);

    for (var _cy = _cy0; _cy <= _cy1; _cy++) {
        for (var _cx = _cx0; _cx <= _cx1; _cx++) {
            var _data = tilemap_get(_tm, _cx, _cy);
            var _tile = tile_get_index(_data);
            if (_tile <= 0 or _tile >= array_length(global.collision_shape)) continue;

            // the part of the rectangle inside this cell, in cell pixels
            var _x0 = max(_l - _cx * COLLISION_CELL, 0);
            var _x1 = min(_r - _cx * COLLISION_CELL, COLLISION_CELL - 1);
            var _y0 = max(_t - _cy * COLLISION_CELL, 0);
            var _y1 = min(_b - _cy * COLLISION_CELL, COLLISION_CELL - 1);
            if (tile_get_mirror(_data)) {
                var _swap = _x0;
                _x0 = COLLISION_CELL - 1 - _x1;
                _x1 = COLLISION_CELL - 1 - _swap;
            }
            var _span = ((1 << (_x1 - _x0 + 1)) - 1) << _x0;
            var _shape = global.collision_shape[_tile];
            var _flip = tile_get_flip(_data);
            for (var _y = _y0; _y <= _y1; _y++) {
                if (_shape[_flip ? COLLISION_CELL - 1 - _y : _y] & _span) return true;
            }
        }
    }
    return false;
}

/// @func world_terrain_blocks(x, y)
/// @desc True if solid terrain (water) is under a room position. A painted Collision tile replaces the
///       terrain for its cell, so bridges and docks over water are walkable wherever their shapes allow
///       (paint the green "walkable" tile where nothing on them should block).
function world_terrain_blocks(_px, _py) {
    return collision_tile_at(_px, _py) == 0 and terrain_solid_at(_px, _py);
}

/// @func world_blocked(x, y)
/// @desc True if the calling instance's collision mask would touch something solid at (x, y):
///       a Collision tile shape, a prop footprint or solid terrain.
function world_blocked(_x, _y) {
    var _dx = _x - x;
    var _dy = _y - y;
    var _l = bbox_left + _dx;
    var _t = bbox_top + _dy;
    var _r = bbox_right + _dx;
    var _b = bbox_bottom + _dy;
    if (collision_rect_solid(_l, _t, _r, _b)) return true;
    if (place_meeting(_x, _y, obj_prop)) return true;
    return world_terrain_blocks(_l, _t) or world_terrain_blocks(_r, _t)
        or world_terrain_blocks(_l, _b) or world_terrain_blocks(_r, _b);
}

/// @func world_move(dx, dy)
/// @desc Moves the calling instance pixel by pixel, stopping at solids. When moving along one axis only,
///       a blocked step may shift one pixel sideways instead, so slopes such as bridge arches and
///       diagonal walls are followed rather than stopping the walk.
function world_move(_dx, _dy) {
    var _sx = sign(_dx);
    var _sy = sign(_dy);
    repeat (abs(_dx)) {
        if (!world_blocked(x + _sx, y)) {
            x += _sx;
        } else if (_dy == 0 and !world_blocked(x + _sx, y - 1)) {
            x += _sx;
            y -= 1;
        } else if (_dy == 0 and !world_blocked(x + _sx, y + 1)) {
            x += _sx;
            y += 1;
        } else {
            break;
        }
    }
    repeat (abs(_dy)) {
        if (!world_blocked(x, y + _sy)) {
            y += _sy;
        } else if (_dx == 0 and !world_blocked(x - 1, y + _sy)) {
            x -= 1;
            y += _sy;
        } else if (_dx == 0 and !world_blocked(x + 1, y + _sy)) {
            x += 1;
            y += _sy;
        } else {
            break;
        }
    }
}
