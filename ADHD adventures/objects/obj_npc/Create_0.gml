// Dialogue is set per instance in its Creation Code (runs after this event), e.g.
//   speaker  = "Old Man";                        // optional, shown above the box
//   dialogue = ["Hello there!", "Nice day, isn't it?"];
dialogue   = [];
speaker    = "";
talk_range = 24;   // px between the player's feet and this NPC
text_speed = 1;    // characters revealed per step

line  = 0;         // current line in dialogue[]
shown = 0;         // characters of that line revealed so far

// the NPC currently talking (noone when no dialogue is open)
if (!variable_global_exists("dialogue_npc")) global.dialogue_npc = noone;

// shared dialogue font: SDF so font_enable_effects can give it a black outline
if (!variable_global_exists("dialogue_font"))
{
	global.dialogue_font = font_add("supersoft.ttf", 28, false, false, 32, 127);
	font_enable_sdf(global.dialogue_font, true);
	font_sdf_spread(global.dialogue_font, 8);
	font_enable_effects(global.dialogue_font, true, {
		outlineEnable: true,
		outlineDistance: 3,
		outlineColour: c_black,
	});
}
