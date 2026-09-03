function scr_dir_to_angle(dir) {
    switch (dir) {
        case "right": return 180;
        case "up":    return 270;
        case "left":  return 0;
        case "down":  return 90;
    }
    return 0;
}