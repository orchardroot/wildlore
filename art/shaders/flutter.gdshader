shader_type spatial;
render_mode cull_disabled, specular_disabled;
// Cloth in the wind: bunting, flags, washing. Meshes lie in the local XY plane; vertex alpha is how free a
// point is (0 = pinned to its string or pole), and it ripples along local z. `wind` follows the weather.
uniform float wind = 1.0;
uniform float speed = 3.2;

vec3 to_linear(vec3 c) {
	return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c));
}

void vertex() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float free = COLOR.a;
	float ph = world.x * 1.7 + world.z * 1.3;
	float ripple = sin(TIME * speed + VERTEX.x * 7.0 + ph) + 0.5 * sin(TIME * speed * 1.9 + VERTEX.y * 9.0 + ph * 0.7);
	VERTEX.z += ripple * 0.05 * wind * free;
	VERTEX.y -= abs(ripple) * 0.012 * wind * free;
	NORMAL = vec3(0.0, 0.8, 0.6);  // cloth hangs either way round: light it from above so it never goes dark
}

void fragment() {
	// like the solid material's vertex_color_is_srgb: convert only when the output is linear (the Compatibility
	// renderer works in sRGB, so there the colour is used as written)
	ALBEDO = OUTPUT_IS_SRGB ? COLOR.rgb : to_linear(COLOR.rgb);
	ROUGHNESS = 1.0;
}
