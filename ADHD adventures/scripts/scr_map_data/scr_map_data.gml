// Terrain types for the map grid
#macro T_GRASS 0
#macro T_PATH  1
#macro T_WATER 2

// Tileset grid: all MPO transparent tilesets are 256px / 32px = 8 columns
#macro TS_COLS 8

// Auto-tile block positions in ts_01_outdoor (col, row of the 4x4 block's top-left)
// If edges look wrong, open the tileset in GameMaker's Tileset Editor
// and adjust these to point at the correct 4x4 auto-tile block.
#macro AT_GRASS_COL 0
#macro AT_GRASS_ROW 17

#macro AT_WATER_COL 0
#macro AT_WATER_ROW 25

// Designed map area size (in tiles)
#macro MAP_W 80
#macro MAP_H 60

// Tile offset where the designed town starts in the room
#macro MAP_X 220
#macro MAP_Y 120

/// @desc Read a cell from the map grid; out-of-bounds counts as grass
function grid_get(_grid, _r, _c) {
    if (_r < 0 || _r >= MAP_H || _c < 0 || _c >= MAP_W) return T_GRASS;
    return _grid[_r][_c];
}

/// @desc Build a 16-entry auto-tile lookup from a 4x4 block at (sc, sr).
///       The 4x4 block in the tileset is laid out as:
///         [OuterTL] [EdgeTop ] [EdgeTop ] [OuterTR]
///         [EdgeLft] [Center  ] [Center  ] [EdgeRgt]
///         [EdgeLft] [Center  ] [Center  ] [EdgeRgt]
///         [OuterBL] [EdgeBot ] [EdgeBot ] [OuterBR]
///       Index by 4-bit neighbour mask: W=1 E=2 S=4 N=8
///       A set bit means that neighbour IS the same terrain.
function build_autotile(_sc, _sr) {
    var _a = array_create(16);
    var _C = TS_COLS;
    var _cen = (_sr + 1) * _C + (_sc + 1);

    _a[0]  = _cen;                             // 0000 isolated
    _a[1]  = (_sr + 1) * _C + (_sc + 3);       // 0001 W only        → right edge
    _a[2]  = (_sr + 1) * _C + (_sc + 0);       // 0010 E only        → left edge
    _a[3]  = _cen;                             // 0011 E+W           → centre
    _a[4]  = (_sr + 0) * _C + (_sc + 1);       // 0100 S only        → top edge
    _a[5]  = (_sr + 0) * _C + (_sc + 3);       // 0101 S+W           → outer TR
    _a[6]  = (_sr + 0) * _C + (_sc + 0);       // 0110 S+E           → outer TL
    _a[7]  = (_sr + 0) * _C + (_sc + 1);       // 0111 S+E+W         → top edge
    _a[8]  = (_sr + 3) * _C + (_sc + 1);       // 1000 N only        → bottom edge
    _a[9]  = (_sr + 3) * _C + (_sc + 3);       // 1001 N+W           → outer BR
    _a[10] = (_sr + 3) * _C + (_sc + 0);       // 1010 N+E           → outer BL
    _a[11] = (_sr + 3) * _C + (_sc + 1);       // 1011 N+E+W         → bottom edge
    _a[12] = _cen;                             // 1100 N+S           → centre
    _a[13] = (_sr + 1) * _C + (_sc + 3);       // 1101 N+S+W         → right edge
    _a[14] = (_sr + 1) * _C + (_sc + 0);       // 1110 N+S+E         → left edge
    _a[15] = _cen;                             // 1111 all neighbours → centre
    return _a;
}

/// @desc Get 4-bit neighbour mask for auto-tiling
function neighbor_mask(_grid, _r, _c, _type) {
    var _w = (grid_get(_grid, _r, _c - 1) == _type) ? 1 : 0;
    var _e = (grid_get(_grid, _r, _c + 1) == _type) ? 2 : 0;
    var _s = (grid_get(_grid, _r + 1, _c) == _type) ? 4 : 0;
    var _n = (grid_get(_grid, _r - 1, _c) == _type) ? 8 : 0;
    return _w | _e | _s | _n;
}

/// @desc Stamp a rectangular region of tiles from a tileset onto a tilemap.
///       src_col/src_row = top-left tile in the tileset sprite.
///       w/h = size in tiles.  dst_col/dst_row = position in the tilemap.
function stamp_tiles(_tm, _src_col, _src_row, _w, _h, _dst_col, _dst_row) {
    for (var _r = 0; _r < _h; _r++) {
        for (var _c = 0; _c < _w; _c++) {
            var _idx = (_src_row + _r) * TS_COLS + (_src_col + _c);
            if (_idx > 0) {
                tilemap_set(_tm, _idx, _dst_col + _c, _dst_row + _r);
            }
        }
    }
}

/// @desc Build the terrain grid that defines the town layout.
///       Returns a 2-D array [MAP_H][MAP_W] of terrain types.
function create_town_grid() {
    // Start with grass everywhere
    var _g = array_create(MAP_H);
    for (var _i = 0; _i < MAP_H; _i++) {
        _g[_i] = array_create(MAP_W, T_GRASS);
    }

    // --- ROADS --------------------------------------------------------
    // Main east-west road (3 tiles wide, row 29 = player row)
    for (var _c = 0; _c < MAP_W; _c++) {
        _g[28][_c] = T_PATH;
        _g[29][_c] = T_PATH;
        _g[30][_c] = T_PATH;
    }
    // Main north-south road (3 tiles wide, col 39 = player col)
    for (var _r = 0; _r < MAP_H; _r++) {
        _g[_r][38] = T_PATH;
        _g[_r][39] = T_PATH;
        _g[_r][40] = T_PATH;
    }

    // Central plaza (9x9 around the crossroads)
    for (var _r = 25; _r <= 33; _r++)
        for (var _c = 35; _c <= 43; _c++)
            _g[_r][_c] = T_PATH;

    // Northwest branch
    for (var _r = 20; _r <= 28; _r++) { _g[_r][16] = T_PATH; _g[_r][17] = T_PATH; }
    for (var _c = 17; _c <= 38; _c++) { _g[20][_c] = T_PATH; _g[21][_c] = T_PATH; }

    // Northeast branch
    for (var _c = 40; _c <= 52; _c++) { _g[20][_c] = T_PATH; _g[21][_c] = T_PATH; }

    // Southwest branch
    for (var _r = 30; _r <= 44; _r++) { _g[_r][16] = T_PATH; _g[_r][17] = T_PATH; }
    for (var _c = 17; _c <= 38; _c++) { _g[42][_c] = T_PATH; _g[43][_c] = T_PATH; }

    // Southeast branch
    for (var _c = 40; _c <= 52; _c++) { _g[42][_c] = T_PATH; _g[43][_c] = T_PATH; }

    // --- POND ---------------------------------------------------------
    var _px = 62, _py = 12, _prx = 5, _pry = 4;
    for (var _r = _py - _pry; _r <= _py + _pry; _r++) {
        for (var _c = _px - _prx; _c <= _px + _prx; _c++) {
            if (_r >= 0 && _r < MAP_H && _c >= 0 && _c < MAP_W) {
                var _dr = (_r - _py) / _pry;
                var _dc = (_c - _px) / _prx;
                if (_dr * _dr + _dc * _dc <= 1)
                    _g[_r][_c] = T_WATER;
            }
        }
    }

    // --- BUILDING FOOTPRINTS ------------------------------------------
    // Clear grass under buildings so paths show beneath them.
    // NW building footprint (8x6 at grid 12,14)
    for (var _r = 14; _r < 20; _r++)
        for (var _c = 12; _c < 20; _c++)
            _g[_r][_c] = T_PATH;

    // NE building footprint (8x8 at grid 48,13)
    for (var _r = 13; _r < 21; _r++)
        for (var _c = 48; _c < 56; _c++)
            _g[_r][_c] = T_PATH;

    // SW building footprint (8x6 at grid 12,38)
    for (var _r = 38; _r < 44; _r++)
        for (var _c = 12; _c < 20; _c++)
            _g[_r][_c] = T_PATH;

    // SE building footprint (8x7 at grid 48,38)
    for (var _r = 38; _r < 45; _r++)
        for (var _c = 48; _c < 56; _c++)
            _g[_r][_c] = T_PATH;

    return _g;
}
