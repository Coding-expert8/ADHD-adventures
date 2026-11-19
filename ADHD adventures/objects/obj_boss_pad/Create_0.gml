// The way to the boss, in the middle of the stone square with the pillars (room_map).
// Standing on it shows six pills around the player: one lit for each minigame beaten
// (beaten_count), the rest as empty outlines. With all six lit the ground glows, a "Q"
// floats over it, and Q takes the player to the boss room.
boss_room = Room3;

radius_x = 64;          // the pad on the ground (an oval, like the minigame portals)
radius_y = 26;
depth    = 650;         // on the ground: under the player and props

icon_radius_x = 70;     // the ring of pills around the player
icon_radius_y = 56;
icon_scale    = 0.5;    // spr_key is 64 px; the pill itself is x 6-58, y 17-54
show  = 0;              // 0 -> 1 fade of the pill ring while standing on the pad
inside = false;
lit    = 0;
