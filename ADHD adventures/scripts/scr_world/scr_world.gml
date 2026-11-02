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

/// @func collision_ramp_at(x, y)
/// @desc How far a ramp tile under a room position moves a walker down (negative = up) per pixel walked
///       to the right. 0 when there is no ramp. Mirrored or flipped ramp tiles slope the other way.
function collision_ramp_at(_px, _py) {
    if (global.tm_collision == -1) return 0;
    var _data = tilemap_get_at_pixel(global.tm_collision, _px, _py);
    if (_data == -1) return 0;
    var _tile = tile_get_index(_data);
    if (_tile >= array_length(global.collision_ramp)) return 0;
    var _rate = global.collision_ramp[_tile];
    if (tile_get_mirror(_data) != tile_get_flip(_data)) _rate = -_rate;
    return _rate;
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

/// @func collision_speed_rect(left, top, right, bottom)
/// @desc Slowest speed fraction of the Collision tiles a rectangle touches (1 = normal speed).
///       Orange tile 27 (vertical stairs) gives 0.7.
function collision_speed_rect(_l, _t, _r, _b) {
    var _tm = global.tm_collision;
    if (_tm == -1) return 1;
    var _cx0 = max(floor(_l / COLLISION_CELL), 0);
    var _cy0 = max(floor(_t / COLLISION_CELL), 0);
    var _cx1 = min(floor(_r / COLLISION_CELL), tilemap_get_width(_tm) - 1);
    var _cy1 = min(floor(_b / COLLISION_CELL), tilemap_get_height(_tm) - 1);
    var _speed = 1;
    for (var _cy = _cy0; _cy <= _cy1; _cy++) {
        for (var _cx = _cx0; _cx <= _cx1; _cx++) {
            var _tile = tile_get_index(tilemap_get(_tm, _cx, _cy));
            if (_tile > 0 and _tile < array_length(global.collision_speed)) _speed = min(_speed, global.collision_speed[_tile]);
        }
    }
    return _speed;
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
///       a Collision tile shape, a cliff wall, a prop footprint or solid terrain.
function world_blocked(_x, _y) {
    var _dx = _x - x;
    var _dy = _y - y;
    var _l = bbox_left + _dx;
    var _t = bbox_top + _dy;
    var _r = bbox_right + _dx;
    var _b = bbox_bottom + _dy;
    if (collision_rect_solid(_l, _t, _r, _b)) return true;
    if (cliff_blocks_rect(_l, _t, _r, _b)) return true;
    if (place_meeting(_x, _y, obj_prop)) return true;
    return world_terrain_blocks(_l, _t) or world_terrain_blocks(_r, _t)
        or world_terrain_blocks(_l, _b) or world_terrain_blocks(_r, _b);
}

/// @func world_move(dx, dy)
/// @desc Moves the calling instance pixel by pixel, stopping at solids.
///       - Walking sideways over ramp tiles (bridge decks, side stairs) also moves it up or down.
///       - When moving along one axis only, a blocked step may shift one pixel sideways instead, so
///         sloped walls are followed rather than stopping the walk.
///       - While the feet touch a slow tile (stairs), the move is scaled down to that tile's speed.
function world_move(_dx, _dy) {
    if (!variable_instance_exists(id, "ramp_carry")) ramp_carry = 0; // fraction of a pixel still to climb
    if (!variable_instance_exists(id, "slow_carry_x")) {
        slow_carry_x = 0; // fractions of a pixel left over from slowed moves
        slow_carry_y = 0;
    }
    var _speed = collision_speed_rect(bbox_left, bbox_top, bbox_right, bbox_bottom);
    if (_speed < 1) {
        slow_carry_x += _dx * _speed;
        slow_carry_y += _dy * _speed;
        _dx = (slow_carry_x < 0) ? ceil(slow_carry_x) : floor(slow_carry_x);
        _dy = (slow_carry_y < 0) ? ceil(slow_carry_y) : floor(slow_carry_y);
        slow_carry_x -= _dx;
        slow_carry_y -= _dy;
    } else {
        slow_carry_x = 0;
        slow_carry_y = 0;
    }

    var _sx = sign(_dx);
    var _sy = sign(_dy);
    repeat (abs(_dx)) {
        var _rate = collision_ramp_at(x, bbox_bottom);
        ramp_carry = (_rate == 0) ? 0 : ramp_carry + _rate * _sx;
        var _lift = 0;
        if (ramp_carry >= 1) _lift = 1;
        if (ramp_carry <= -1) _lift = -1;
        ramp_carry -= _lift;

        if (_lift != 0 and !world_blocked(x + _sx, y + _lift)) {
            x += _sx;
            y += _lift;
        } else if (!world_blocked(x + _sx, y)) {
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
