// A patch of the map that is simply darker than the daylight says it should be:
// the foot of a cliff, under a bridge, the inside of a treeline. Drag one into a
// room and stretch it over the spot -- the box you see in the editor is the extent
// of the shade, and spr_trigger is only the handle for grabbing it.
//
// Set shade_strength per instance in the Variable Definitions panel, or in the
// instance's creation code. 0 is nothing, 1 is black. These are guards, not
// defaults you should rely on: they catch an empty field or a typo.
if (!variable_instance_exists(id, "shade_strength")) shade_strength = SHADE_STRENGTH_DEFAULT;
if (!is_real(shade_strength)) shade_strength = SHADE_STRENGTH_DEFAULT;
shade_strength = clamp(shade_strength, 0, 1);

// In front of the ground and of the Y-sorted props and player, so walking in puts
// the player in the shade too -- but still in the layer pass, which is before
// every Draw End event. That is what leaves the day/night tint and the lamps on
// top of it: shade is part of the world, so the sky still has to get at it, and a
// lamp standing in it still has to be able to light it back up.
depth = SHADE_DEPTH;
