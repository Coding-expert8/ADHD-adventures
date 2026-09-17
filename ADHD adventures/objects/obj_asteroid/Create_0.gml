sprite_index = choose(spr_asteroid_large, spr_asteroid_medium, spr_asteroid_small);
image_index = irandom(6);
direction = irandom_range(0, 359);
image_angle = irandom_range(0, 359);
speed = 1;
image_speed = 0;

//make it ice theme
//asteroids can be huge snowballs
//accuracy tracker