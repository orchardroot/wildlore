shader_type spatial;
render_mode specular_disabled;
// Vertex-coloured train cars, cut off at the map edge and at tunnel mouths so they slide in and out of view.
// Vertices with colour alpha below 0.5 are windows and lamps: they glow at night.
uniform vec2 clip_min = vec2(-10000.0);
uniform vec2 clip_max = vec2(10000.0);
uniform float glow = 0.0;
varying vec3 world;

vec3 to_linear(vec3 c) {
	return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c));
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	if (world.x < clip_min.x || world.z < clip_min.y || world.x > clip_max.x || world.z > clip_max.y) {
		discard;
	}
	vec3 c = to_linear(COLOR.rgb);
	ALBEDO = c;
	ROUGHNESS = 1.0;
	if (COLOR.a < 0.5) {
		EMISSION = vec3(1.0, 0.8, 0.45) * glow * 0.6;
	}
}
