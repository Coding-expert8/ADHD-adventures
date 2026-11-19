// A teleport point on room_map. Set in the instance's Creation Code:
//   area_name = "town";   // the obj_area area_name it belongs to (must match exactly)
//   label     = "Town";   // name shown on the pause board's minimap
// Shows a star once the player has walked into that area (area_is_discovered, see scr_teleport),
// a lock until then. Teleporting happens from the TELEPORT tab of the pause board (obj_help).
area_name = "";
label = "";
depth = 650; // on the ground: above the Below tile layers, under the player and props
