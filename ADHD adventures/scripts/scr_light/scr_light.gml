#macro LAMP_GLOW_RADIUS 120
#macro LAMP_GLOW_ALPHA  0.22
#macro LAMP_CORE_RADIUS 40
#macro LAMP_CORE_ALPHA  0.30

#macro LAMP_GLOW_COLOUR make_colour_rgb(255, 196, 108)

#macro LAMP_BULB_FRACTION 0.20

function prop_object_for(_sprite) {
    switch (_sprite) {
        case spr_prop_forest_lamp:
        case spr_prop_town_lamp:
        case spr_prop_desert_lamp:
        case spr_prop_city_lamp_double:
            return obj_lamp
        default:
            return obj_prop
    }
}
