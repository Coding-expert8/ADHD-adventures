// ============================================================
//  MAP BUILDER  –  populates every tile layer in room_map
// ============================================================

// 1. Build the terrain grid -----------------------------------
var _grid = create_town_grid();

// 2. Prepare auto-tile lookups --------------------------------
var _grass_at = build_autotile(AT_GRASS_COL, AT_GRASS_ROW);
var _water_at = build_autotile(AT_WATER_COL, AT_WATER_ROW);

// 3. Get tile-layer handles -----------------------------------
var _ground = layer_tilemap_get_id("Tiles_Ground");
var _struct = layer_tilemap_get_id("Tiles_Structures");
var _bldg   = layer_tilemap_get_id("Tiles_Buildings");

var _room_cols = room_width  div 32;
var _room_rows = ceil(room_height / 32);

// 4. Fill entire room with grass centre tile ------------------
var _grass_cen = _grass_at[15];
for (var _r = 0; _r < _room_rows; _r++)
    for (var _c = 0; _c < _room_cols; _c++)
        tilemap_set(_ground, _grass_cen, _c, _r);

// 5. Auto-tile the designed town area -------------------------
//    Loop 1 tile beyond the grid in every direction so grass
//    edges appear cleanly where paths meet the rest of the room.
for (var _r = -1; _r <= MAP_H; _r++) {
    for (var _c = -1; _c <= MAP_W; _c++) {
        var _ac = MAP_X + _c;
        var _ar = MAP_Y + _r;
        if (_ac < 0 || _ac >= _room_cols || _ar < 0 || _ar >= _room_rows) continue;

        var _type = grid_get(_grid, _r, _c);

        switch (_type) {
            case T_GRASS:
                var _m = neighbor_mask(_grid, _r, _c, T_GRASS);
                tilemap_set(_ground, _grass_at[_m], _ac, _ar);
                break;

            case T_WATER:
                var _m = neighbor_mask(_grid, _r, _c, T_WATER);
                tilemap_set(_ground, _water_at[_m], _ac, _ar);
                break;

            case T_PATH:
                tilemap_set(_ground, 0, _ac, _ar);
                break;
        }
    }
}

// 6. Stamp buildings ------------------------------------------
// Building 1 – red-roof house from ts_01 (NW of plaza)
//   Source: cols 0-7, rows 39-44.  Adjust if the building looks wrong.
stamp_tiles(_struct, 0, 39, 8, 6,  MAP_X + 12, MAP_Y + 14);

// Building 2 – dark-city building from ts_02 (NE of plaza)
//   Source: cols 0-7, rows 24-31.
stamp_tiles(_bldg, 0, 24, 8, 8,   MAP_X + 48, MAP_Y + 13);

// Building 3 – second red-roof house (SW of plaza)
stamp_tiles(_struct, 0, 39, 8, 6,  MAP_X + 12, MAP_Y + 38);

// Building 4 – another dark-city section from ts_02 (SE of plaza)
stamp_tiles(_bldg, 0, 32, 8, 7,   MAP_X + 48, MAP_Y + 38);

// 7. Stamp decorations ----------------------------------------

// Trees from ts_01  (approx cols 4-7, rows 9-12 → 4x4 tiles each)
stamp_tiles(_struct, 4, 9, 4, 4,   MAP_X + 4,  MAP_Y + 4);
stamp_tiles(_struct, 4, 9, 4, 4,   MAP_X + 24, MAP_Y + 6);
stamp_tiles(_struct, 4, 9, 4, 4,   MAP_X + 68, MAP_Y + 35);
stamp_tiles(_struct, 4, 9, 4, 4,   MAP_X + 72, MAP_Y + 4);
stamp_tiles(_struct, 4, 9, 4, 4,   MAP_X + 4,  MAP_Y + 50);
stamp_tiles(_struct, 4, 9, 4, 4,   MAP_X + 30, MAP_Y + 48);
stamp_tiles(_struct, 4, 9, 4, 4,   MAP_X + 62, MAP_Y + 50);

// Bushes from ts_01  (2x2 tiles, three colour variants in cols 0-5, rows 3-4)
stamp_tiles(_struct, 0, 3, 2, 2,   MAP_X + 3,  MAP_Y + 25);
stamp_tiles(_struct, 0, 3, 2, 2,   MAP_X + 75, MAP_Y + 15);
stamp_tiles(_struct, 2, 3, 2, 2,   MAP_X + 30, MAP_Y + 14);
stamp_tiles(_struct, 4, 3, 2, 2,   MAP_X + 60, MAP_Y + 25);
stamp_tiles(_struct, 0, 3, 2, 2,   MAP_X + 8,  MAP_Y + 48);
stamp_tiles(_struct, 2, 3, 2, 2,   MAP_X + 68, MAP_Y + 44);

// Large rock from ts_01  (cols 0-3, rows 9-12 → 4x4)
stamp_tiles(_struct, 0, 9, 4, 4,   MAP_X + 72, MAP_Y + 28);

// Fence pieces from ts_01  (approx cols 4-7, rows 13-14 → 4x2)
stamp_tiles(_struct, 4, 13, 4, 2,  MAP_X + 34, MAP_Y + 24);
stamp_tiles(_struct, 4, 13, 4, 2,  MAP_X + 34, MAP_Y + 34);
