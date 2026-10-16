shader_type spatial;
render_mode specular_disabled;
// Boats and buoys riding the water: the same swell as water.gdshader (same TIME base and phase across the
// world), so each instance bobs in step with the water round it, plus a gentle roll and pitch.
uniform float amount = 1.0;

void vertex() {
	vec3 o = MODEL_MATRIX[3].xyz;
	float ph = o.x * 1.7 + o.z * 1.1;
	float roll = sin(TIME * 0.9 + ph) * 0.05 * amount;
	float pitch = sin(TIME * 0.7 + ph * 1.3 + 1.0) * 0.025 * amount;
	vec3 v = VERTEX;
	// small-angle roll about local x and pitch about local z, then the swell
	v.y += v.z * roll + v.x * pitch;
	v.z -= VERTEX.y * roll;
	v.x -= VERTEX.y * pitch;
	v.y += sin(TIME * 1.2 + ph) * 0.05 * amount;
	VERTEX = v;
}

void fragment() {
	ALBEDO = COLOR.rgb;  // vertex colours arrive linear here, as the solid material sees them
	ROUGHNESS = 1.0;
}
