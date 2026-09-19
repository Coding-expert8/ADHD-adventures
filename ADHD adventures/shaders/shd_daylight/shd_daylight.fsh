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
//   - a pool of light around the sun (or the moon) as it arcs across the view
//   - a vignette that only shows up once the tint is dark anyway
//
varying vec2 v_pos;        // 0..1 across the view

uniform float u_phase;     // 0..1 through the day
uniform float u_aspect;    // view width / height, so the light pool stays round
uniform float u_strength;  // 0 = no tint at all, 1 = the full cycle

const float PI = 3.14159265;

// Tint colours. Alpha is how much of the world the tint covers, so day is clear.
const vec4 COL_NIGHT = vec4(0.11, 0.17, 0.42, 0.62);
const vec4 COL_DAWN  = vec4(0.98, 0.57, 0.33, 0.36);
const vec4 COL_DAY   = vec4(1.00, 0.98, 0.88, 0.00);
const vec4 COL_DUSK  = vec4(0.95, 0.40, 0.29, 0.40);

const vec3 GLOW_SUN  = vec3(1.00, 0.86, 0.60);
const vec3 GLOW_MOON = vec3(0.72, 0.82, 1.00);

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
    // The sun crosses the view left to right between sunrise (0.25) and sunset
    // (0.75); the moon does the same over the other half of the day, which is
    // what fract() wraps to. arc is 0 as it rises and 1 as it sets.
    float arc  = fract((u_phase - 0.25) * 2.0);
    float high = sin(arc * PI);                        // 0 at the horizon, 1 overhead

    // Just under the bottom edge at the horizon, near the top at its peak.
    vec2  light = vec2(arc, 1.05 - 0.95 * high);
    float dist  = distance(v_pos * vec2(u_aspect, 1.0), light * vec2(u_aspect, 1.0));
    float glow  = 1.0 - smoothstep(0.0, 0.85, dist);

    // A low sun throws long warm light over everything; overhead there is barely
    // anything to see, because the daytime tint is already clear.
    glow *= mix(0.90, 0.20, high);

    // Fade the light in as it clears the horizon and out again as it sets, so the
    // hand-over between sun and moon never pops.
    glow *= smoothstep(0.0, 0.06, arc) * (1.0 - smoothstep(0.94, 1.0, arc));

    // Warm while the sun is up, cool while the moon is.
    float moon = step(0.75, u_phase) + (1.0 - step(0.25, u_phase));
    tint.rgb = mix(tint.rgb, mix(GLOW_SUN, GLOW_MOON, moon), glow);
    tint.a   = mix(tint.a, tint.a * 0.65 + 0.10, glow * 0.8);

    // --- vignette ------------------------------------------------------------
    // Corners fall off into the dark. Scaled by the tint's own alpha, so midday
    // stays completely flat.
    float edge = smoothstep(0.35, 0.85, distance(v_pos, vec2(0.5, 0.5)));
    tint.a += edge * tint.a * 0.45;

    gl_FragColor = vec4(tint.rgb, clamp(tint.a, 0.0, 1.0) * u_strength);
}
