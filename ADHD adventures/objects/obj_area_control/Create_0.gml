// Tracks which area the player is standing in and drives its theme + weather.
global.current_area  = noone;   // the obj_area instance the player is inside (or noone)
global.current_theme = noone;   // the sound asset currently playing as the theme

fade_snd = noone;               // a theme fading out, waiting to be stopped
FADE_MS  = 600;                 // theme fade in/out length
