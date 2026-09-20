// Cliffs ("plateaus"), drawn from the hidden "Cliff" tile layer.
//
// Paint the walkable TOP of a plateau with a kit's palette tile (tiles 1..cliff_count of ts_cliff).
// obj_cliff then draws its edges: the top edge row, the surface, the left and right caps, and the
// wall in the cells below it. Because every piece is picked from the painted shape, a cliff always
// gets its start and end caps - there is no way to paint a run that stops halfway.
//
// The wall blocks walkers (see cliff_blocks_rect), as do the drawn rims along the top and sides, so
// the only way up is a gap: paint the green "walkable" tile of the Collision layer over the cells a
// staircase covers, which turns cliff blocking off for those cells.

#macro CLIFF_CELL 32

global.tm_cliff = -1;   // tilemap of the "Cliff" layer, set by obj_world

/// @func cliff_at_cell(cell_x, cell_y)
/// @desc Cliff kit painted in a cell: 0 = none or outside the layer, -1 = not a palette tile.
function cliff_at_cell(_cx, _cy) {
    var _tm = global.tm_cliff;
    if (_tm == -1) return 0;
    if (_cx < 0 or _cy < 0 or _cx >= tilemap_get_width(_tm) or _cy >= tilemap_get_height(_tm)) return 0;
    var _kit = tile_get_index(tilemap_get(_tm, _cx, _cy));
    return (_kit <= global.cliff_count) ? _kit : -1;
}

/// @func cliff_column(kit, cell_x, cell_y)
/// @desc Which of the kit's three columns a cell uses: 0 left cap, 1 middle, 2 right cap.
function cliff_column(_kit, _cx, _cy) {
    if (cliff_at_cell(_cx - 1, _cy) != _kit) return 0;
    if (cliff_at_cell(_cx + 1, _cy) != _kit) return 2;
    return 1;
}

/// @func cliff_draw_view()
/// @desc Draws every plateau visible in the view, and marks unpainted kits in F1 debug view.
function cliff_draw_view() {
    if (global.tm_cliff == -1) return;
    var _view = world_view_rect();
    var _x0 = floor(_view[0] / CLIFF_CELL) - 1;
    var _y0 = floor(_view[1] / CLIFF_CELL) - 1 - global.cliff_face_max;  // a plateau above the view still walls into it
    var _x1 = floor((_view[0] + _view[2]) / CLIFF_CELL) + 1;
    var _y1 = floor((_view[1] + _view[3]) / CLIFF_CELL) + 1;
    var _bad = [];

    for (var _cy = _y1; _cy >= _y0; _cy--) {       // bottom-up, so a wall never covers the plateau below it
        for (var _cx = _x0; _cx <= _x1; _cx++) {
            var _kit = cliff_at_cell(_cx, _cy);
            if (_kit == -1 and global.world_debug) array_push(_bad, _cx, _cy);
            if (_kit <= 0) continue;
            var _info = global.cliff_kit[_kit];
            var _col = cliff_column(_kit, _cx, _cy);
            var _row = (cliff_at_cell(_cx, _cy - 1) == _kit) ? 1 : 0;   // 0 = top edge, 1 = surface
            draw_tile(ts_cliff, _info.base + _row * 3 + _col, 0, _cx * CLIFF_CELL, _cy * CLIFF_CELL);

            if (cliff_at_cell(_cx, _cy + 1) != _kit) {                  // wall below the bottom edge
                for (var _i = 0; _i < _info.face_rows; _i++) {
                    draw_tile(ts_cliff, _info.base + (2 + _i) * 3 + _col, 0,
                              _cx * CLIFF_CELL, (_cy + 1 + _i) * CLIFF_CELL);
                }
            }
        }
    }

    if (array_length(_bad) == 0) return;
    draw_set_colour(c_fuchsia);
    for (var _i = 0; _i < array_length(_bad); _i += 2) {
        var _px = _bad[_i] * CLIFF_CELL;
        var _py = _bad[_i + 1] * CLIFF_CELL;
        draw_line_width(_px, _py, _px + CLIFF_CELL, _py + CLIFF_CELL, 3);
        draw_line_width(_px, _py + CLIFF_CELL, _px + CLIFF_CELL, _py, 3);
    }
    draw_set_colour(c_white);
}

/// @func cliff_blocks_rect(left, top, right, bottom)
/// @desc True if a rectangle (inclusive room coordinates) touches a cliff wall or one of the rims
///       drawn along a plateau's top and sides. A cell with a painted Collision tile is skipped, so
///       the green "walkable" tile cuts a staircase through a cliff.
function cliff_blocks_rect(_l, _t, _r, _b) {
    if (global.tm_cliff == -1) return false;
    var _cx0 = floor(_l / CLIFF_CELL);
    var _cy0 = floor(_t / CLIFF_CELL);
    var _cx1 = floor(_r / CLIFF_CELL);
    var _cy1 = floor(_b / CLIFF_CELL);

    for (var _cy = _cy0; _cy <= _cy1; _cy++) {
        for (var _cx = _cx0; _cx <= _cx1; _cx++) {
            var _px = _cx * CLIFF_CELL;
            var _py = _cy * CLIFF_CELL;
            if (collision_tile_at(_px + 8, _py + 8) != 0 or collision_tile_at(_px + 24, _py + 8) != 0
                or collision_tile_at(_px + 8, _py + 24) != 0 or collision_tile_at(_px + 24, _py + 24) != 0) continue;
            var _kit = cliff_at_cell(_cx, _cy);

            if (_kit > 0) {
                var _info = global.cliff_kit[_kit];
                if (cliff_at_cell(_cx, _cy - 1) != _kit and _t < _py + _info.rim_top) return true;
                if (cliff_at_cell(_cx - 1, _cy) != _kit and _l < _px + _info.rim_left) return true;
                if (cliff_at_cell(_cx + 1, _cy) != _kit and _r > _px + CLIFF_CELL - 1 - _info.rim_right) return true;
                continue;
            }

            // a cell below a plateau is wall for as many rows as that kit's face is tall
            for (var _up = 1; _up <= global.cliff_face_max; _up++) {
                var _above = cliff_at_cell(_cx, _cy - _up);
                if (_above <= 0) continue;
                if (cliff_at_cell(_cx, _cy - _up + 1) == _above) continue;  // not the bottom edge
                if (_up <= global.cliff_kit[_above].face_rows) return true;
            }
        }
    }
    return false;
}
