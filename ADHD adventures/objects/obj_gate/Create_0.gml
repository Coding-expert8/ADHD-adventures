// A barrier on room_map that stays until a minigame has been beaten.
// Set in the instance's Creation Code:
//   unlock = "tinyhouse_beaten";        // name of the global flag that opens it (see obj_key)
//   sprite_index = spr_prop_ice_rock;   // optional: barrier art instead of the red block
// It's a prop (obj_prop child), so it blocks the player with its sprite mask and is Y-sorted.
//   Visible gate:   set sprite_index to barrier art (rocks, a fence...).
//   Invisible gate: keep spr_gate, untick Visible, and stretch it across the gap.
event_inherited();
unlock = "";
