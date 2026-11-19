// Dialogue is set per instance in its Creation Code (runs after this event), e.g.
//   speaker     = "Old Man";                     // optional, shown above the box
//   dialogue    = ["Hello there!", "Nice day, isn't it?"];
//   target_room = room_fishing;                  // optional: when the talk ends, a portal to this room
//                                                //   (obj_minigame_portal) opens next to the NPC
//   fade        = true;                          // (no longer used: the portal always fades)
//   star_colour = make_color_rgb(60, 140, 255);  // optional: colour of the star over a major NPC
// Major NPCs (the ones that start a minigame) set target_room and get a floating star
// in their minigame's colour; small NPCs only talk.
dialogue    = [];
speaker     = "";
target_room = noone;
portal      = noone; // the obj_minigame_portal this NPC opened

// Said by the major NPC whose minigame was the last of the six (scr_save: boss_message_pending).
boss_lines  = [
	"You did it, that's all six pills!",
	"The way to the boss is open now.",
	"Go to the big stone square with the pillars, south of the village.",
	"Stand in the middle of it and press Q. Good luck!",
];
boss_talk   = false; // true while saying boss_lines (normal dialogue is kept in saved_dialogue)
saved_dialogue = [];
fade        = false;
star_colour = make_color_rgb(255, 205, 60); // gold unless the instance picks a theme colour
talk_range = 24;   // px between the player's feet and this NPC
text_speed = 1;    // characters revealed per step

line  = 0;         // current line in dialogue[]
shown = 0;         // characters of that line revealed so far

// the NPC currently talking (noone when no dialogue is open)
if (!variable_global_exists("dialogue_npc")) global.dialogue_npc = noone;

// shared dialogue font: SDF so font_enable_effects can give it a black outline
if (!variable_global_exists("dialogue_font"))
{
	global.dialogue_font = font_add("supersoft.ttf", 30, false, false, 32, 127);
	font_enable_sdf(global.dialogue_font, true);
	font_sdf_spread(global.dialogue_font, 8);
	font_enable_effects(global.dialogue_font, true, {
		outlineEnable: true,
		outlineDistance: 2,
		outlineColour: c_black,
	});
}

// the words the NPC speaks: 1.5x the dialogue font (28 -> 42), same outline
if (!variable_global_exists("dialogue_text_font"))
{
	global.dialogue_text_font = font_add("supersoft.ttf", 42, false, false, 32, 127);
	font_enable_sdf(global.dialogue_text_font, true);
	font_sdf_spread(global.dialogue_text_font, 8);
	font_enable_effects(global.dialogue_text_font, true, {
		outlineEnable: true,
		outlineDistance: 2,
		outlineColour: c_black,
	});
}

// Opens this NPC's minigame portal (obj_minigame_portal) near it: the closest spot around the
// NPC that the player can walk straight to from where they are standing. If there is none,
// it opens at the player's feet (it only works once they have stepped out of it).
// Does nothing if this NPC's portal is already open.
open_portal = function()
{
	if (instance_exists(portal) or !instance_exists(obj_player)) return;

	var _cx = (bbox_left + bbox_right) / 2;
	var _cy = bbox_bottom;                       // the NPC's feet
	var _pl = obj_player;
	var _off = _pl.y - _pl.bbox_bottom;          // player origin relative to its feet
	var _fx = (_pl.bbox_left + _pl.bbox_right) / 2;
	var _fy = _pl.bbox_bottom;
	var _px = _fx;
	var _py = _fy;
	var _best = infinity;

	for (var _r = 50; _r <= 150; _r += 20)
	{
		for (var _a = 0; _a < 360; _a += 30)
		{
			var _sx = _cx + lengthdir_x(_r, _a);
			var _sy = _cy + lengthdir_y(_r, _a);
			if (point_distance(_sx, _sy, _fx, _fy) < 60) continue;      // not on top of the player
			var _cost = _r + ((_sy < _cy - 10) ? 60 : 0);              // beside or in front beats behind
			if (_cost >= _best) continue;

			// the player must fit there and be able to walk straight to it
			var _ok = true;
			with (_pl)
			{
				if (world_blocked(_sx - 20, _sy + _off) or world_blocked(_sx + 20, _sy + _off)) _ok = false;
				var _steps = ceil(point_distance(_fx, _fy, _sx, _sy) / 6);
				for (var _k = 1; _ok and _k <= _steps; _k++)
				{
					if (world_blocked(lerp(_fx, _sx, _k / _steps), lerp(_fy, _sy, _k / _steps) + _off)) _ok = false;
				}
			}
			if (_ok) { _px = _sx; _py = _sy; _best = _cost; }
		}
	}

	portal = instance_create_depth(_px, _py, 0, obj_minigame_portal);
	portal.target_room = target_room;
	portal.colour = star_colour;
}
