shader_type spatial;
render_mode specular_schlick_ggx, cull_back;
// Stylised water: two-tone ripples with a sparkle, slightly see-through at the edges.
// Medium and High graphics add `detail` (0 on Low, which looks as it always has): foam lapping at the shore
// (vertex COLOR.r, 1 where a corner touches land, from ZoneBuilder), the sky's colour in the water at a glancing
// angle (`sky`, set by SkyAndLight from the time of day) and a moving glitter of sunlight.
uniform vec3 deep : source_color = vec3(0.13, 0.32, 0.42);
uniform vec3 shallow : source_color = vec3(0.36, 0.62, 0.66);
uniform vec3 foam : source_color = vec3(0.85, 0.93, 0.95);
uniform float detail = 0.0;
uniform vec3 sky : source_color = vec3(0.62, 0.76, 0.86);

varying vec3 world_pos;
varying float shore;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	shore = 1.0 - COLOR.g;  // white (old meshes) means open water
	VERTEX.y += sin(TIME * 1.2 + world_pos.x * 1.7 + world_pos.z * 1.1) * 0.015;
}

void fragment() {
	float r = sin(world_pos.x * 3.1 + TIME * 1.3) * 0.5 + sin(world_pos.z * 2.3 - TIME * 1.1) * 0.5;
	float r2 = sin((world_pos.x + world_pos.z) * 5.0 + TIME * 2.0);
	vec3 col = mix(deep, shallow, 0.5 + 0.3 * r);
	col = mix(col, foam, smoothstep(0.985, 1.0, r2 * r) * 0.25);
	float alpha = 0.88;
	if (detail > 0.0) {
		// the sky in the water, strongest at a glancing angle (towards the top of the screen)
		float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
		col = mix(col, sky, clamp(fres * 1.2 + 0.04, 0.0, 0.35) * detail);
		// foam: a soft band at the shore that laps in and out, broken up so it never reads as a stripe
		float n = vnoise(world_pos.xz * 3.0 + vec2(TIME * 0.25, -TIME * 0.18));
		float lap = 0.55 + 0.45 * sin(TIME * 1.4 + world_pos.x * 0.9 + world_pos.z * 0.7);
		float edge = smoothstep(0.35, 0.95, shore * lap + (n - 0.5) * 0.35);
		col = mix(col, foam, edge * 0.7 * detail);
		alpha = mix(alpha, 0.94, edge * detail);
		// glitter: a sparse field of points that wink in the light
		float g = vnoise(world_pos.xz * 14.0 + vec2(TIME * 0.6, TIME * 0.4));
		col += foam * smoothstep(0.86, 0.97, g) * 0.18 * detail * (1.0 - edge);
	}
	ALBEDO = col;
	ROUGHNESS = 0.12;
	SPECULAR = 0.7;
	ALPHA = alpha;
}
