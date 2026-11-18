// Discovered areas and the teleport points (obj_teleport_point) on room_map.
//
// global.discovered_areas is a struct of area_name -> true. obj_area_control adds an area the
// first time the player walks into it, and scr_save keeps the list in save.ini. A teleport point
// shows a star (can teleport there) once its area is discovered, and a lock until then.
// The HELP board's TELEPORTATION tab draws the same points on the minimap (spr_teleport_map).

// room_map size the minimap image (240 x 158) was made from
#macro TELEPORT_WORLD_W 18000
#macro TELEPORT_WORLD_H 12000
#macro TELEPORT_MAP_W   240
#macro TELEPORT_MAP_H   158
#macro TELEPORT_ICON_HIT 9   // click / hover radius of a minimap icon, in GUI pixels

/// @func area_discover(name)
/// @desc Marks an area as discovered. Returns true if it is new.
function area_discover(_name) {
	if (_name == "" or area_is_discovered(_name)) return false;
	global.discovered_areas[$ _name] = true;
	return true;
}

/// @func area_is_discovered(name)
function area_is_discovered(_name) {
	return variable_struct_exists(global.discovered_areas, _name);
}

/// @func discovered_areas_to_string()
/// @desc "village,town,..." for save.ini
function discovered_areas_to_string() {
	var _names = variable_struct_get_names(global.discovered_areas);
	var _s = "";
	for (var _i = 0; _i < array_length(_names); _i++) {
		if (_i > 0) _s += ",";
		_s += _names[_i];
	}
	return _s;
}

/// @func discovered_areas_from_string(s)
function discovered_areas_from_string(_s) {
	global.discovered_areas = {};
	var _names = string_split(_s, ",", true);
	for (var _i = 0; _i < array_length(_names); _i++) {
		area_discover(string_trim(_names[_i]));
	}
}

/// @func teleport_map_x(world_x, image_x)
/// @desc GUI x of a room_map position on the minimap drawn at image_x.
function teleport_map_x(_wx, _image_x) {
	return _image_x + _wx / TELEPORT_WORLD_W * TELEPORT_MAP_W;
}

/// @func teleport_map_y(world_y, image_y)
function teleport_map_y(_wy, _image_y) {
	return _image_y + _wy / TELEPORT_WORLD_H * TELEPORT_MAP_H;
}

/// @func teleport_point_at(mx, my, image_x, image_y)
/// @desc The obj_teleport_point whose minimap icon is under (mx, my), or noone.
function teleport_point_at(_mx, _my, _image_x, _image_y) {
	var _best = noone;
	var _best_d = TELEPORT_ICON_HIT;
	with (obj_teleport_point) {
		var _d = point_distance(_mx, _my, teleport_map_x(x, _image_x), teleport_map_y(y, _image_y));
		if (_d <= _best_d) {
			_best = id;
			_best_d = _d;
		}
	}
	return _best;
}

/// @func draw_teleport_star(x, y, r)
/// @desc Gold five-pointed star of outer radius r.
function draw_teleport_star(_x, _y, _r) {
	var _inner = _r * 0.45;

	draw_set_color(make_color_rgb(255, 205, 60));
	draw_primitive_begin(pr_trianglefan);
	draw_vertex(_x, _y);
	for (var _i = 0; _i <= 10; _i++) {
		var _a = 90 + _i * 36;
		var _rr = (_i mod 2 == 0) ? _r : _inner;
		draw_vertex(_x + lengthdir_x(_rr, _a), _y + lengthdir_y(_rr, _a));
	}
	draw_primitive_end();

	draw_set_color(make_color_rgb(140, 85, 20));
	draw_primitive_begin(pr_linestrip);
	for (var _i = 0; _i <= 10; _i++) {
		var _a = 90 + _i * 36;
		var _rr = (_i mod 2 == 0) ? _r : _inner;
		draw_vertex(_x + lengthdir_x(_rr, _a), _y + lengthdir_y(_rr, _a));
	}
	draw_primitive_end();
	draw_set_color(c_white);
}

/// @func draw_teleport_lock(x, y, r)
/// @desc Grey padlock that fits in a circle of radius r.
function draw_teleport_lock(_x, _y, _r) {
	var _bw = _r * 0.8;          // half width of the body
	var _top = _y - _r * 0.1;    // top of the body
	var _bot = _y + _r * 0.9;

	// shackle: an arch of short thick lines above the body
	draw_set_color(make_color_rgb(70, 70, 78));
	var _sr = _r * 0.5;
	var _sw = max(1, _r * 0.22);
	var _px = _x - _sr;
	var _py = _top;
	for (var _a = 180; _a >= 0; _a -= 20) {
		var _nx = _x + lengthdir_x(_sr, _a);
		var _ny = _top - _r * 0.25 + lengthdir_y(_sr, _a);
		draw_line_width(_px, _py, _nx, _ny, _sw);
		_px = _nx;
		_py = _ny;
	}
	draw_line_width(_px, _py, _x + _sr, _top, _sw);

	// body
	draw_set_color(make_color_rgb(150, 150, 160));
	draw_rectangle(_x - _bw, _top, _x + _bw, _bot, false);
	draw_set_color(make_color_rgb(70, 70, 78));
	draw_rectangle(_x - _bw, _top, _x + _bw, _bot, true);

	// keyhole
	draw_circle(_x, _top + (_bot - _top) * 0.4, max(1, _r * 0.15), false);
	draw_set_color(c_white);
}

/// @func draw_teleport_icon(x, y, r, discovered)
function draw_teleport_icon(_x, _y, _r, _discovered) {
	if (_discovered) draw_teleport_star(_x, _y, _r);
	else draw_teleport_lock(_x, _y, _r);
}
