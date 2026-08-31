
function scr_power_type_to_frame(type) {
    switch (type) {
        case "slow":         return 0;
        case "fast":         return 1;
        case "double_score": return 2;
        case "shrink":       return 3;
        case "ghost":        return 4;
    }
    return 0;
}