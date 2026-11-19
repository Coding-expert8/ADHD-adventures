fade_elapsed += delta_time / 1000000;

// Alpha moves smoothly from 1 (fully black) to 0 (fully transparent).
fade_alpha = 1 - clamp(fade_elapsed / fade_duration, 0, 1);

// Once the fade is complete, remove the overlay object. It will not interfere
// with later room drawing or input.
if (fade_elapsed >= fade_duration) {
    fade_alpha = 0;
    instance_destroy();
}