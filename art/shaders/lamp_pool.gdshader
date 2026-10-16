shader_type spatial;
render_mode blend_add, unshaded, depth_draw_never, cull_disabled, fog_disabled;
// A fake pool of lamplight on the ground: an additive radial gradient, one quad per lamp post. `strength`
// follows the lamps' glow (0 by day) from SkyAndLight.
uniform float strength = 0.0;
uniform vec3 tint : source_color = vec3(1.0, 0.72, 0.36);

void fragment() {
	float d = length(UV * 2.0 - 1.0);
	float a = clamp(1.0 - d, 0.0, 1.0);
	a = a * a * (3.0 - 2.0 * a);
	ALBEDO = tint * a * strength * 0.5;
	ALPHA = 1.0;
}
