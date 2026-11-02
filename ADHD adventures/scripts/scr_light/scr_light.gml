// Light and its absence. obj_lamp draws a pool of light around its bulb, scaled by
// daylight_darkness(), so the lamps come up through dusk and go out through dawn along with
// shd_daylight's tint rather than on a clock of their own. obj_shade is the other half: a
// patch of the map marked out by hand as darker than the daylight says it should be.

// The pool is two circles, not one. draw_circle_colour interpolates colour from the centre
// to the rim but holds alpha flat, so a single circle falls off in a straight line and reads
// as a shaded disc. A wide dim one for the spill plus a tight bright one over the bulb add
// up to a curve that reads as light falling away.
#macro LAMP_GLOW_RADIUS 120    // pixels of spill at image_yscale 1 -- the view is 640x360
#macro LAMP_GLOW_ALPHA  0.22   // how much of that spill is added at deep night
#macro LAMP_CORE_RADIUS 40     // the bright part right around the bulb
#macro LAMP_CORE_ALPHA  0.30

// Warm, and nowhere near white. Under bm_add the colour is added straight onto what is
// already on screen, so anything close to white pushes the pixels under it to flat white
// instead of lighting them. Holding the blue channel down keeps the pool reading as
// lamplight, and the two alphas together peak around half, which lifts the night without
// clipping the ground to a white disc.
#macro LAMP_GLOW_COLOUR make_colour_rgb(255, 196, 108)

// Where the bulb sits on a lamp sprite, as a fraction of its height down from the top.
// These sprites are anchored at their top-left corner and the light is up at the head, not
// down at the base, so the glow has to be lifted by hand. Measured off the art -- the
// centroid of each sprite's lit pixels sits at 0.215 (forest), 0.175 (town), 0.217 (desert)
// and 0.244 (city double) of its height, and on the sprite's centre line in x.
#macro LAMP_BULB_FRACTION 0.20

// --- shade -------------------------------------------------------------------------------
// obj_shade boxes, dragged over the places that should be darker than the sky is making
// them: the foot of a cliff, under a bridge, inside a treeline.

#macro SHADE_STRENGTH_DEFAULT 0.25  // how far down a shade box with no value set pulls light
#macro SHADE_DEPTH            -50   // over the ground, props and player; under the sky

// Shade on a sunless night is shade of nothing: there is no sun left to be out of, and the
// night tint has already taken the light away. So most of it lifts after dark rather than
// stacking up into a black hole. Set this to 0 to keep shade at full strength round the clock.
#macro SHADE_NIGHT_FADE 0.70

// --- shade -------------------------------------------------------------------
// The other half of lighting: ground that the light does not reach. obj_shade
// marks a region out and darkens it (see objects/obj_shade). These are its
// defaults; any instance can override them in its creation code.
#macro SHADE_COVER   0.22   // how much of the world a region covers at its centre
#macro SHADE_FEATHER 48     // pixels its edges fade over -- the whole look is the edge
#macro SHADE_COLOUR  make_colour_rgb(22, 30, 54)   // skylight without the sun: cool, not black

// How much of the shade the night takes away. Shade is the absence of direct
// light, so at midnight there is nothing left for a cliff to stand in the way of
// and the patch all but disappears.


/// @func prop_object_for(sprite)
/// @desc Which object a sprite on a room's "Props" asset layer should become. Scenery is
///       scenery unless the world has to know more about it than where it stands -- a lamp
///       has to light the ground around it at night. Deciding it from the sprite here means
///       lamps are still placed as plain sprites in the room editor, with no per-instance
///       setup and no room file to keep in step.
function prop_object_for(_sprite) {
    switch (_sprite) {
        case spr_prop_forest_lamp:
        case spr_prop_town_lamp:
        case spr_prop_desert_lamp:
        case spr_prop_city_lamp_double:
            return obj_lamp;
        default:
            return obj_prop;
    }
}
