// Rain only ever has to cover what the camera is looking at, so the emitters
// follow the view instead of blanketing the whole room.
var _v  = world_view_rect();
var _vx = _v[0], _vy = _v[1], _vw = _v[2], _vh = _v[3];

// Drops spawn in a band just above the view. Slanted rain drifts sideways on
// the way down, so widen the band by that drift or the upwind edge stays dry.
var _drift = _vh * abs(dcos(rain_dir) / dsin(rain_dir));
part_emitter_region(rain_ps, rain_em_drops,
    _vx - _drift, _vx + _vw + _drift,
    _vy - 80, _vy - 16,
    ps_shape_rectangle, ps_distr_linear);
part_emitter_burst(rain_ps, rain_em_drops, rain_pt_drop, rain_density);

// Splashes pop anywhere on screen, as if drops were landing all over it.
part_emitter_region(rain_ps, rain_em_splashes,
    _vx, _vx + _vw,
    _vy, _vy + _vh,
    ps_shape_rectangle, ps_distr_linear);
part_emitter_burst(rain_ps, rain_em_splashes, rain_pt_splash, rain_splashes);
