// Stop the footstep loop with the player. Audio outlives a room change, and
// rooms without an obj_player have nothing to turn it off, so leaving it to the
// Step event's guard would strand the loop running in the next room.
sfx_loop_set(snd_walk, false, 0);
