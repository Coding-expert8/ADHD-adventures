// An invisible region of the map. When the player is inside it, obj_area_control
// plays area_theme (a sound, or none) and applies area_profile as the weather.
// Stretch this instance in the room editor to cover the region; set area_theme
// and area_profile per instance (Variable Definitions or Creation Code).
if (!variable_instance_exists(id, "area_theme"))   area_theme = noone;
if (!variable_instance_exists(id, "area_profile")) area_profile = WEATHER_PROFILE_RAIN;
if (!variable_instance_exists(id, "area_name"))    area_name = "";

// An Asset property with nothing chosen can arrive as "", undefined or -1, so
// anything that isn't a real sound counts as "no theme".
if (!is_real(area_theme) or !audio_exists(area_theme)) area_theme = noone;
if (!is_real(area_profile) or area_profile < 0 or area_profile > 3) area_profile = WEATHER_PROFILE_RAIN;
