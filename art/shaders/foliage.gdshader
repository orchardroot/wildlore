shader_type spatial;
render_mode cull_disabled, specular_disabled;
// Vertex-coloured foliage that sways in the wind. Higher vertices move more.
uniform float wind_strength = 0.035;
uniform float wind_speed = 1.3;

vec3 to_linear(vec3 c) {
	return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c));
}

void vertex() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float w = max(VERTEX.y, 0.0);
	float sway = sin(TIME * wind_speed + world.x * 0.7 + world.z * 0.45) * wind_strength * w;
	sway += sin(TIME * wind_speed * 2.3 + world.z * 1.3) * wind_strength * 0.35 * w;
	VERTEX.x += sway;
	VERTEX.z += sway * 0.5;
}

void fragment() {
	// like the solid material's vertex_color_is_srgb: convert only when the output is linear (the Compatibility
	// renderer works in sRGB, so there the colour is used as written)
	ALBEDO = OUTPUT_IS_SRGB ? COLOR.rgb : to_linear(COLOR.rgb);
	ROUGHNESS = 1.0;
}
