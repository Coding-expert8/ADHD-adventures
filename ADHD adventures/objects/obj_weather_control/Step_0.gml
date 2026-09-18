// Weather only ever has to cover what the camera is looking at, so the emitters
// follow the view instead of blanketing the whole room.
var _v  = world_view_rect();
var _vx = _v[0], _vy = _v[1], _vw = _v[2], _vh = _v[3];

switch (global.weather) {

    case WEATHER_RAIN:
        // Drops spawn in a band just above the view. Slanted rain drifts
        // sideways on the way down, so widen the band by that drift or the
        // upwind edge stays dry.
        var _drift = _vh * abs(dcos(rain_dir) / dsin(rain_dir));
        part_emitter_region(weather_ps, rain_em_drops,
            _vx - _drift, _vx + _vw + _drift,
            _vy - 80, _vy - 16,
            ps_shape_rectangle, ps_distr_linear);
        part_emitter_burst(weather_ps, rain_em_drops, rain_pt_drop, rain_density);

        // Splashes pop anywhere on screen, as if drops were landing all over it.
        part_emitter_region(weather_ps, rain_em_splashes,
            _vx, _vx + _vw,
            _vy, _vy + _vh,
            ps_shape_rectangle, ps_distr_linear);
        part_emitter_burst(weather_ps, rain_em_splashes, rain_pt_splash, rain_splashes);
        break;

    case WEATHER_SNOW:
        // Same band as rain, but flakes wander much further sideways over their
        // long fall, so the overscan is generous.
        var _snow_drift = _vh * abs(dcos(snow_dir) / dsin(snow_dir)) + _vw * 0.5;
        part_emitter_region(weather_ps, snow_em_flakes,
            _vx - _snow_drift, _vx + _vw + _snow_drift,
            _vy - 96, _vy - 16,
            ps_shape_rectangle, ps_distr_linear);
        part_emitter_burst(weather_ps, snow_em_flakes, snow_pt_flake, snow_density);
        break;

    case WEATHER_SANDSTORM:
        // The wind is near-horizontal, so sand blows in from the side of the
        // view it is coming from, not from above. Grains sag as they cross, so
        // the band runs taller than the view by that sag.
        var _sag  = _vw * abs(dsin(sand_dir) / dcos(sand_dir));
        var _edge = (dcos(sand_dir) < 0) ? _vx + _vw + 16 : _vx - 80;
        part_emitter_region(weather_ps, sand_em_grains,
            _edge, _edge + 64,
            _vy - _sag, _vy + _vh + _sag,
            ps_shape_rectangle, ps_distr_linear);
        part_emitter_burst(weather_ps, sand_em_grains, sand_pt_grain, sand_density);

        // Gusts move slower than the grains, so they get their own wider band.
        part_emitter_region(weather_ps, sand_em_gusts,
            _edge - 64, _edge + 128,
            _vy - _sag, _vy + _vh + _sag,
            ps_shape_rectangle, ps_distr_linear);
        part_emitter_burst(weather_ps, sand_em_gusts, sand_pt_gust, sand_gusts);
        break;

    // WEATHER_NONE (and anything unrecognised) emits nothing; whatever is
    // already in the air finishes its life and the screen clears itself.
}
