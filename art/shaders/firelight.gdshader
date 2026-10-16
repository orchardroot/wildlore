shader_type spatial;
render_mode blend_add, unshaded, depth_draw_never, cull_disabled, fog_disabled;
// Hearth fire and the glow it throws: additive, vertex rgb times alpha, flickering out of step per fireplace.
varying float flick;

void vertex() {
	float ph = MODEL_MATRIX[3].x * 3.1 + MODEL_MATRIX[3].z * 1.7;
	flick = 0.82 + 0.12 * sin(TIME * 9.0 + ph) + 0.06 * sin(TIME * 23.0 + ph * 2.0);
	VERTEX.y *= 1.0 + 0.18 * (flick - 0.82) * step(0.1, VERTEX.y);
}

void fragment() {
	ALBEDO = COLOR.rgb * COLOR.a * flick;
	ALPHA = 1.0;
}
