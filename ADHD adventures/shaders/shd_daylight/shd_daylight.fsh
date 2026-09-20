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
//   - a wash of light coming in from the side the sun (or the moon) is on
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
const vec4 COL_DAWN  = vec4(0.72, 0.55, 0.48, 0.22);
const vec4 COL_DAY   = vec4(1.00, 0.98, 0.88, 0.00);
const vec4 COL_DUSK  = vec4(0.62, 0.42, 0.44, 0.26);

const vec3 GLOW_SUN  = vec3(0.98, 0.90, 0.78);
const vec3 GLOW_MOON = vec3(0.55, 0.66, 0.92);

void main()
{
    // --- base tint -----------------------------------------------------------
    // Each mix finishes before the next one starts, so the chain reads as a
    // timeline: night until 0.17, sunrise through 0.25, full day from 0.36,
    // sunset through 0.78, night again from 0.92.
    vec4 tint = COL_NIGHT;
    tint = mix(tint, COL_DAWN,  smoothstep(0.17, 0.25, u_phase));
    tint = mix(tint, COL_DAY,   smoothstep(0.27, 0.36, u_phase));
    tint = mix(tint, COL_DUSK,  smoothstep(0.66, 0.78, u_phase));
    tint = mix(tint, COL_NIGHT, smoothstep(0.82, 0.92, u_phase));

    // --- sun / moon ----------------------------------------------------------
    // The sun is up between sunrise (0.25) and sunset (0.75); the moon has the
    // other half of the day, which is what fract() wraps to. arc is 0 as it rises
    // and 1 as it sets.
    float arc  = fract((u_phase - 0.25) * 2.0);
    float high = sin(arc * PI);                        // 0 at the horizon, 1 overhead

    // This is a map seen from above, so there is no sky on screen to put the sun
    // in: screen Y is ground running north to south, not height. What a low sun
    // does to a top-down view is light one side of it and leave the other in
    // shade, so that is what this draws -- a wash coming in from the side the
    // light is on. East is the left-hand edge of this map, so the light starts
    // there at sunrise and walks right across the day.
    float across = abs(v_pos.x - arc);                 // 0 on the sun's side, 1 at the far edge

    // Low, the light rakes in from one side and falls away across the view. As it
    // climbs the two sides even out. Overhead it settles to a low even level rather
    // than lighting the whole view at full strength: a flat wash over everything is
    // just haze, and the midday tint is meant to be clear.
    float glow = mix(1.0 - smoothstep(0.0, 0.9, across), 0.35, high);

    // A low sun throws long light over everything; overhead there is barely
    // anything to see, because the daytime tint is already clear. Kept well under
    // half strength so the wash colours the light rather than fogging the view.
    glow *= mix(0.55, 0.12, high);

    // Fade the light in as it clears the horizon and out again as it sets, so the
    // hand-over between sun and moon never pops. At that moment the light jumps
    // from one edge of the view to the other, so everything that depends on which
    // side it is on has to be faded out by this, not just the wash.
    float risen = smoothstep(0.0, 0.06, arc) * (1.0 - smoothstep(0.94, 1.0, arc));
    glow *= risen;

    // Warm while the sun is up, cool while the moon is.
    float moon = step(0.75, u_phase) + (1.0 - step(0.25, u_phase));
    tint.rgb = mix(tint.rgb, mix(GLOW_SUN, GLOW_MOON, moon), glow);
    tint.a   = mix(tint.a, tint.a * 0.80 + 0.04, glow * 0.7);

    // The side the light never reached is the shaded one. The wash above lifts the
    // lit side, but on its own that is only visible when the tint is already strong,
    // which is to say at dawn and dusk -- through the middle of the day the tint is
    // clear and there is nothing to lift. So the far side gets its own shade rather
    // than a share of the tint's: a darker version of whatever colour the light is,
    // laid on a little more thickly. That is what carries the direction
    // through the morning and afternoon. It closes up as the sun climbs, because
    // overhead there is no side for the light to come from.
    float shade = across * (1.0 - high) * risen;
    tint.rgb = mix(tint.rgb, tint.rgb * 0.45, shade);
    tint.a  += shade * 0.10;

    // --- vignette ------------------------------------------------------------
    // Corners fall off into the dark. Scaled by the tint's own alpha, so midday
    // stays completely flat.
    float edge = smoothstep(0.35, 0.85, distance(v_pos, vec2(0.5, 0.5)));
    tint.a += edge * tint.a * 0.30;

    gl_FragColor = vec4(tint.rgb, clamp(tint.a, 0.0, 1.0) * u_strength);
}
