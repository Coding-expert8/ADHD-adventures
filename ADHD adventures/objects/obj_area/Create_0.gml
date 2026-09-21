if (!variable_instance_exists(id, "area_theme"))   area_theme = noone
if (!variable_instance_exists(id, "area_profile")) area_profile = WEATHER_PROFILE_RAIN
if (!variable_instance_exists(id, "area_name"))    area_name = ""

if (!is_real(area_theme) or !audio_exists(area_theme)) area_theme = noone
if (!is_real(area_profile) or area_profile < 0 or area_profile > 3) area_profile = WEATHER_PROFILE_RAIN
