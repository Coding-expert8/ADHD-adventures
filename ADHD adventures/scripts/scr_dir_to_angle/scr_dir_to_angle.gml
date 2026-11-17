function scr_dir_to_angle(dir) {
    switch (dir) {
        case "right": return 270;
        case "up":    return 0;
        case "left":  return 90;
        case "down":  return 180;
    }
    return 0;
}