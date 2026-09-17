#macro T_GRASS  0
#macro T_PATH   1
#macro T_WATER  2

#macro TS_COLS  8

#macro AT_GRASS_COL  0
#macro AT_GRASS_ROW  17
#macro AT_WATER_COL  0
#macro AT_WATER_ROW  25

#macro MAP_W  80
#macro MAP_H  60
#macro MAP_X  220
#macro MAP_Y  120

function grid_get(_grid, _r, _c) {
    if (_r < 0 || _r >= MAP_H || _c < 0 || _c >= MAP_W) return T_GRASS;
    return _grid[_r][_c];
}

function build_autotile(_sc, _sr) {
    var _lut = array_create(16, 0);
    _lut[0]  = (_sr + 0) * TS_COLS + (_sc + 0);
    _lut[2]  = (_sr + 0) * TS_COLS + (_sc + 1);
    _lut[1]  = (_sr + 0) * TS_COLS + (_sc + 2);
    _lut[3]  = (_sr + 0) * TS_COLS + (_sc + 3);
    _lut[8]  = (_sr + 1) * TS_COLS + (_sc + 0);
    _lut[10] = (_sr + 1) * TS_COLS + (_sc + 1);
    _lut[9]  = (_sr + 1) * TS_COLS + (_sc + 2);
    _lut[11] = (_sr + 1) * TS_COLS + (_sc + 3);
    _lut[4]  = (_sr + 2) * TS_COLS + (_sc + 0);
    _lut[6]  = (_sr + 2) * TS_COLS + (_sc + 1);
    _lut[5]  = (_sr + 2) * TS_COLS + (_sc + 2);
    _lut[7]  = (_sr + 2) * TS_COLS + (_sc + 3);
    _lut[12] = (_sr + 3) * TS_COLS + (_sc + 0);
    _lut[14] = (_sr + 3) * TS_COLS + (_sc + 1);
    _lut[13] = (_sr + 3) * TS_COLS + (_sc + 2);
    _lut[15] = (_sr + 3) * TS_COLS + (_sc + 3);
    return _lut;
}

function neighbor_mask(_grid, _r, _c, _type) {
    var _m = 0;
    if (grid_get(_grid, _r, _c - 1) == _type) _m |= 1;
    if (grid_get(_grid, _r, _c + 1) == _type) _m |= 2;
    if (grid_get(_grid, _r + 1, _c) == _type) _m |= 4;
    if (grid_get(_grid, _r - 1, _c) == _type) _m |= 8;
    return _m;
}

function stamp_tiles(_tm, _src_col, _src_row, _w, _h, _dst_col, _dst_row) {
    for (var _r = 0; _r < _h; _r++)
        for (var _c = 0; _c < _w; _c++)
            tilemap_set(_tm, (_src_row + _r) * TS_COLS + (_src_col + _c), _dst_col + _c, _dst_row + _r);
}

function create_town_grid() {
    var _g = array_create(MAP_H);
    for (var _r = 0; _r < MAP_H; _r++) {
        _g[_r] = array_create(MAP_W, T_GRASS);
    }

    for (var _r = 0; _r < MAP_H; _r++)
        for (var _c = 38; _c <= 40; _c++)
            _g[_r][_c] = T_PATH;

    for (var _c = 0; _c < MAP_W; _c++)
        for (var _r = 28; _r <= 30; _r++)
            _g[_r][_c] = T_PATH;

    for (var _r = 25; _r <= 33; _r++)
        for (var _c = 35; _c <= 43; _c++)
            _g[_r][_c] = T_PATH;

    for (var _r = 14; _r <= 20; _r++)
        for (var _c = 10; _c <= 12; _c++)
            _g[_r][_c] = T_PATH;
    for (var _r = 14; _r <= 20; _r++)
        for (var _c = 56; _c <= 58; _c++)
            _g[_r][_c] = T_PATH;
    for (var _r = 38; _r <= 46; _r++)
        for (var _c = 10; _c <= 12; _c++)
            _g[_r][_c] = T_PATH;
    for (var _r = 38; _r <= 46; _r++)
        for (var _c = 56; _c <= 58; _c++)
            _g[_r][_c] = T_PATH;

    var _cx = 62; var _cy = 12;
    for (var _r = _cy - 5; _r <= _cy + 5; _r++)
        for (var _c = _cx - 7; _c <= _cx + 7; _c++) {
            var _dx = (_c - _cx) / 7.0;
            var _dy = (_r - _cy) / 5.0;
            if (_dx*_dx + _dy*_dy <= 1.0)
                if (_r >= 0 && _r < MAP_H && _c >= 0 && _c < MAP_W)
                    _g[_r][_c] = T_WATER;
        }

    for (var _r = 14; _r <= 19; _r++)
        for (var _c = 12; _c <= 19; _c++)
            _g[_r][_c] = T_PATH;
    for (var _r = 13; _r <= 20; _r++)
        for (var _c = 48; _c <= 55; _c++)
            _g[_r][_c] = T_PATH;
    for (var _r = 38; _r <= 43; _r++)
        for (var _c = 12; _c <= 19; _c++)
            _g[_r][_c] = T_PATH;
    for (var _r = 38; _r <= 44; _r++)
        for (var _c = 48; _c <= 55; _c++)
            _g[_r][_c] = T_PATH;

    return _g;
}