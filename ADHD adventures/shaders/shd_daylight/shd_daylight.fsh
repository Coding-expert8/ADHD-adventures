//
// Day/night overlay -- fragment stage.
//
// Everything here is a function of u_phase, the position in the day:
// 0 = midnight, 0.25 = sunrise, 0.5 = noon, 0.75 = sunset.
//
// The quad is drawn over the view with ordinary alpha blending, so the job is to
// answer, per pixel, "what colour is the light right now and how much of the
// world does it cover?". Three things decide that:
//   - a base tint that walks night -> dawn -> day -> dusk -> night
//   - a light side and a shaded side, split along the bearing the light is on
//   - a vignette that only shows up once the tint is dark anyway
//
varying vec2 v_pos;        // 0..1 across the view

uniform float u_phase;     // 0..1 through the day
uniform float u_strength;  // 0 = no tint at all, 1 = the full cycle

const float PI = 3.14159265;

// Tint colours. Alpha is how much of the world the tint covers, so day is clear.
//
// The alpha-blended result is tint.rgb * a + world * (1 - a), which splits into
// two separate jobs: (1 - a) is how much darker everything gets, and tint.rgb * a
// is a flat veil laid over it. That veil is what reads as haze, so dark times of
// day keep their colours low and lean on alpha for the darkness instead.
const vec4 COL_NIGHT = vec4(0.05, 0.08, 0.22, 0.66);
const vec4 COL_DAWN  = vec4(0.78, 0.55, 0.42, 0.22);
const vec4 COL_DAY   = vec4(1.00, 0.98, 0.88, 0.00);
const vec4 COL_DUSK  = vec4(0.70, 0.44, 0.39, 0.26);

// The colour of being out of the light. Darker than any of the tints above, so that
// laying it over the world darkens it at any hour -- including midday, when the tint
// itself has faded to nothing and there would otherwise be no shade left to cast.
// Not much darker, though: shade is the absence of direct light, not a hole.
const vec3 COL_SHADE = vec3(0.08, 0.10, 0.18);

const vec3 GLOW_SUN  = vec3(0.99, 0.88, 0.72);
const vec3 GLOW_MOON = vec3(0.40, 0.50, 0.75);   // moonlight, not daylight in blue

const float LIGHT_REACH      = 1.6;    // how far across the view the split runs
const float LIGHT_SHARE      = 0.68;   // how much of the view the lit side takes (0.5 = even)
const float LIGHT_PEAK_SLANT = 0.70;   // how much of the split survives at the light's peak
const float LIGHT_LOW_SLANT  = 0.80;   // ...and how much of it there is with the light low
const float LIGHT_WARMTH     = 0.50;   // how much of its own colour the lit side takes
const float LIGHT_HAZE       = 0.10;   // cover the lit side takes on -- the sun's own haze
const float MOON_POWER       = 0.45;   // the moon splits the sides this much less than the sun
const float SHADE_DEPTH      = 0.90;   // how far towards COL_SHADE the shaded side goes
const float SHADE_COVER      = 0.24;   // cover the shaded side takes on of its own

void main()
{
    // --- base tint -----------------------------------------------------------
    // Each mix finishes before the next one starts, and the gap between one ending
    // and the next starting is how long that colour is held: night until 0.15,
    // sunrise reached at 0.24 and held to 0.29, full day from 0.38, sunset reached
    // at 0.75 and held to 0.81, night again from 0.93. Without those gaps the warm
    // colours are passed through rather than sat in, which is what makes a dawn
    // feel like a moment instead of a part of the day.
    vec4 tint = COL_NIGHT;
    tint = mix(tint, COL_DAWN,  smoothstep(0.15, 0.24, u_phase));
    tint = mix(tint, COL_DAY,   smoothstep(0.29, 0.38, u_phase));
    tint = mix(tint, COL_DUSK,  smoothstep(0.63, 0.75, u_phase));
    tint = mix(tint, COL_NIGHT, smoothstep(0.81, 0.93, u_phase));

    // --- where the light is coming from ----------------------------------------
    // The sun is up between sunrise (0.25) and sunset (0.75); the moon has the
    // other half of the day, which is what fract() wraps to. arc is 0 as it rises
    // and 1 as it sets.
    float arc  = fract((u_phase - 0.25) * 2.0);
    float high = sin(arc * PI);                        // 0 at the horizon, 1 at its peak

    // A map seen from above has no sky to put the light in -- screen Y is ground
    // running north to south, not height -- but it does have a compass bearing for
    // the light to arrive on, and that is what sweeps across the day: east as it
    // rises, south at its peak, west as it sets. North is up, so east is the left
    // edge of the view and south is the bottom of it.
    vec2 bearing = vec2(-cos(arc * PI), sin(arc * PI));

    // How far into the light this pixel is: 1 facing it, 0 with its back to it.
    // LIGHT_SHARE is where the line between the two falls. At 0.5 it runs through
    // the middle of the view and the sides come out even; pushing it up walks that
    // line back towards the far corner, so the light the sun is throwing accounts
    // for more of what is on screen and the shade is what is left over. The corner
    // it is thrown from keeps its full depth either way -- this moves the line, not
    // the ends of the gradient.
    float lit = clamp(LIGHT_SHARE + dot(v_pos - vec2(0.5, 0.5), bearing) * LIGHT_REACH, 0.0, 1.0);

    // Fade the light in as it clears the horizon and out again as it sets, so the
    // hand-over from sun to moon -- which swaps the bearing end for end -- never
    // pops. The moon is a far weaker light than the sun and parts the two sides
    // much less.
    float moon  = step(0.75, u_phase) + (1.0 - step(0.25, u_phase));
    float risen = smoothstep(0.0, 0.10, arc) * (1.0 - smoothstep(0.90, 1.0, arc));
    float power = risen * mix(1.0, MOON_POWER, moon);

    // The two sides get their own curves, because they do not grow together. Light
    // rakes in hardest when it is low, so the lit side swells towards the horizon.
    // Shade does not: a long shadow is longer, not blacker, and running the shade
    // up to full strength at dawn is what turns the far side of a sunrise into a
    // dark wall. So it stays near enough level all day.
    float slant = mix(LIGHT_PEAK_SLANT, 1.0,              1.0 - high) * power;
    float shade = mix(LIGHT_PEAK_SLANT, LIGHT_LOW_SLANT,  1.0 - high) * power;

    // The side facing the light takes its colour and a haze of its own; the side
    // away from it goes towards COL_SHADE and takes on cover instead. Giving each
    // side its own colour and its own alpha, rather than a share of the tint's, is
    // what keeps the light readable through the middle of the day, when the tint
    // has faded to nothing for either of them to borrow from.
    tint.rgb = mix(tint.rgb, mix(GLOW_SUN, GLOW_MOON, moon), lit * slant * LIGHT_WARMTH);
    tint.rgb = mix(tint.rgb, COL_SHADE, (1.0 - lit) * shade * SHADE_DEPTH);
    tint.a  += lit * slant * LIGHT_HAZE;
    tint.a  += (1.0 - lit) * shade * SHADE_COVER;

    // --- vignette ------------------------------------------------------------
    // Corners fall off into the dark. Scaled by the tint's own alpha, so it is the
    // shaded side of a midday view that picks this up, not the lit one.
    float edge = smoothstep(0.35, 0.85, distance(v_pos, vec2(0.5, 0.5)));
    tint.a += edge * tint.a * 0.30;

    gl_FragColor = vec4(tint.rgb, clamp(tint.a, 0.0, 1.0) * u_strength);
}
