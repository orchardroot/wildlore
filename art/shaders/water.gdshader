shader_type spatial;
render_mode specular_schlick_ggx, cull_back;
// Stylised water: two-tone ripples with a sparkle, slightly see-through at the edges.
uniform vec3 deep : source_color = vec3(0.13, 0.32, 0.42);
uniform vec3 shallow : source_color = vec3(0.36, 0.62, 0.66);
uniform vec3 foam : source_color = vec3(0.85, 0.93, 0.95);

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y += sin(TIME * 1.2 + world_pos.x * 1.7 + world_pos.z * 1.1) * 0.015;
}

void fragment() {
	float r = sin(world_pos.x * 3.1 + TIME * 1.3) * 0.5 + sin(world_pos.z * 2.3 - TIME * 1.1) * 0.5;
	float r2 = sin((world_pos.x + world_pos.z) * 5.0 + TIME * 2.0);
	vec3 col = mix(deep, shallow, 0.5 + 0.3 * r);
	col = mix(col, foam, smoothstep(0.985, 1.0, r2 * r) * 0.25);
	ALBEDO = col;
	ROUGHNESS = 0.12;
	SPECULAR = 0.7;
	ALPHA = 0.88;
}
