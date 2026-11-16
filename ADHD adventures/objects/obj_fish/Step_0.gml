if (wave) {
    wave_time += wave_speed;
    y = base_y + sin(wave_time) * wave_amplitude;
}

// Remove once it has swum off the other side
if ((hspeed > 0 and x > room_width + 50) or (hspeed < 0 and x < -50)) {
    instance_destroy();
}
