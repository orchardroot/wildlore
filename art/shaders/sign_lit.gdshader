shader_type spatial;
render_mode specular_disabled;
// Sign emblems that light up after dark (the Sanctuary's cross, the Corner Shop's roundel): vertex colour,
// plus a glow of the same colour scaled by `energy`, which SkyAndLight sets with the street lamps.
uniform float energy = 0.0;

vec3 to_linear(vec3 c) {
	return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c));
}

void fragment() {
	// like the solid material's vertex_color_is_srgb: convert only when the output is linear (the Compatibility
	// renderer works in sRGB, so there the colour is used as written)
	vec3 c = OUTPUT_IS_SRGB ? COLOR.rgb : to_linear(COLOR.rgb);
	ALBEDO = c;
	EMISSION = c * energy * 0.45;
	ROUGHNESS = 1.0;
}
