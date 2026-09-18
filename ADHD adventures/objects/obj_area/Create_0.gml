// An invisible region of the map. When the player is inside it, obj_area_control
// plays area_theme (a sound, or none) and applies area_profile as the weather.
// Stretch this instance in the room editor to cover the region; set area_theme
// and area_profile per instance (Variable Definitions or Creation Code).
if (!variable_instance_exists(id, "area_theme"))   area_theme = noone;
if (!variable_instance_exists(id, "area_profile")) area_profile = WEATHER_PROFILE_RAIN;
if (!variable_instance_exists(id, "area_name"))    area_name = "";

// The Asset property leaves area_theme as -1 / "" when no sound is chosen; treat
// anything that isn't a real sound as "no theme".
if (!audio_exists(area_theme)) area_theme = noone;
