shader_type spatial;
render_mode specular_disabled;
// Lit windows. Each pane's vertex colour carries its own night: rgb = how bright the room is (0 = empty and
// dark), alpha = how late it goes out (1 = all night). `lateness` (0 early evening .. 1 small hours) comes
// from SkyAndLight; a pane fades out once the night is later than its bedtime.
uniform float energy = 0.0;
uniform float lateness = 0.0;
uniform vec3 dim : source_color = vec3(0.227, 0.275, 0.345);
uniform vec3 lit : source_color = vec3(1.0, 0.851, 0.541);
uniform vec3 emit : source_color = vec3(1.0, 0.784, 0.376);

void fragment() {
	float on = COLOR.r * smoothstep(lateness - 0.05, lateness, COLOR.a);
	float night = step(0.001, energy);
	ALBEDO = mix(dim, lit, night * on);
	EMISSION = emit * energy * on;
	ROUGHNESS = 1.0;
}
