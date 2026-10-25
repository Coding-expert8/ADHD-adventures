//
// Shade region -- fragment stage.
//
// A soft-edged patch of dark laid over the ground: the foot of a cliff, under a
// bridge, the inside of a doorway. All the work is the edge. A flat rectangle of
// dark reads as a decal someone forgot to delete; what makes it read as shade is
// that it has no edge you can point at.
//
varying vec2 v_pos;        // 0..1 inside the region

uniform vec4 u_colour;     // the colour of the dark, and how much of the world it covers
uniform vec2 u_feather;    // how far in each edge fades, as a fraction of the region

void main()
{
    // How far in from the nearest edge this pixel is, per axis.
    vec2 d = min(v_pos, 1.0 - v_pos);

    // Fade in from both edges on both axes. Multiplying the two axes together,
    // rather than taking the smaller, is what rounds the corners off: near a
    // corner both factors are partway up, so the product dips below either one.
    float m = smoothstep(0.0, u_feather.x, d.x) * smoothstep(0.0, u_feather.y, d.y);

    gl_FragColor = vec4(u_colour.rgb, u_colour.a * m);
}
