shader_type spatial;
render_mode unshaded, cull_disabled;
// A flat little bird (or bat) seen from above: the wings flap by lifting the vertices furthest from the body.
// `glide` > 0 adds long glides between bursts of flapping (gulls). Each bird has its own `phase`.
uniform float rate = 6.0;
uniform float amp = 0.35;
uniform float glide = 0.0;
uniform float phase = 0.0;
uniform float dim = 1.0;

void vertex() {
	float flap = sin(TIME * rate + phase);
	float on = mix(1.0, smoothstep(-0.2, 0.5, sin(TIME * 0.55 + phase * 0.37)), glide);
	VERTEX.y += (flap * on + 0.15 * (1.0 - on)) * amp * abs(VERTEX.x);
}

void fragment() {
	ALBEDO = COLOR.rgb * dim;
}
