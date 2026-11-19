// Minigame portal: a glowing circle on the ground (flat, so it looks like an oval) with light
// rising up from it. A major NPC (obj_npc) creates it when its talk ends; walking into it
// starts that NPC's minigame.
target_room = noone;   // set by the NPC that creates it

radius_x    = 34;      // size of the oval on the ground
radius_y    = 12;
glow_height = 90;      // how far the light rises
colour      = make_color_rgb(120, 220, 255);

armed = false;         // only works once the player has been outside it
grow  = 0;             // 0 -> 1: pops open when it appears
depth = 650;           // on the ground like obj_teleport_point: under the player and props
