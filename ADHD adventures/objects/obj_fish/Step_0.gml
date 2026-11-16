// Remove once it has swum off the other side
if ((hspeed > 0 and x > room_width + 50) or (hspeed < 0 and x < -50)) {
    instance_destroy();
}
