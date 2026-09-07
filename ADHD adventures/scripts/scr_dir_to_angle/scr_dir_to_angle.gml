function scr_dir_to_angle(dir) {
    switch (dir) {
        case "right": return 0;
        case "up":    return 90;
        case "left":  return 180;
        case "down":  return 270;
    }
    return 0;
}