if (!global.world_debug) exit

draw_set_colour(c_yellow)
for (var _i = 0; _i < ds_list_size(sort_list); _i++) {
    with (sort_list[| _i]) draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true)
}
draw_set_colour(c_aqua)
with (par_trigger) draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true)
with (obj_spawn) draw_circle(x, y, 6, true)

if (variable_global_exists("current_area")) {
    draw_set_colour(c_lime)
    with (obj_area) draw_text(bbox_left + 4, bbox_top + 4, area_name)

    var _profiles = ["clear", "rain", "desert", "snow"]
    var _weathers = ["clear", "rain", "snow", "sandstorm"]
    var _in    = (global.current_area  != noone) ? global.current_area.area_name : "(open world)"
    var _theme = (global.current_theme != noone) ? audio_get_name(global.current_theme) : "-"
    var _v = world_view_rect()
    draw_text(_v[0] + 8, _v[1] + 8,
          "area: "      + string(_in)
        + "\nprofile: " + _profiles[global.weather_profile]
        + "\nweather: " + _weathers[global.weather]
        + "\ntheme: "   + _theme
        + "\ntime: "    + daylight_clock_string()
                        + (keyboard_check(DAYLIGHT_FAST_KEY) ? "  x" + string(DAYLIGHT_FAST_SCALE) : "  (hold D)"))
}
draw_set_colour(c_white)
