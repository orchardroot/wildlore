shader_type canvas_item;
// Cave darkness: black everywhere except soft circles of light (the player, plus faint glows on the exits).
uniform vec2 centre = vec2(640.0, 360.0);
uniform float radius = 120.0;
uniform vec4 lights[8];       // xy = screen position, z = radius, w = unused
uniform int light_count = 0;
uniform vec2 size = vec2(1280.0, 720.0);  // the overlay's size in the same pixels as the light positions
uniform vec3 tint : source_color = vec3(0.03, 0.03, 0.06);
uniform float warmth = 0.0;   // the Lantern's orange edge

void fragment() {
	vec2 p = UV * size;
	float lit = 1.0 - smoothstep(radius * 0.55, radius, distance(p, centre));
	for (int i = 0; i < light_count; i++) {
		lit = max(lit, 0.75 * (1.0 - smoothstep(lights[i].z * 0.3, lights[i].z, distance(p, lights[i].xy))));
	}
	float edge = smoothstep(radius * 0.8, radius, distance(p, centre)) * (1.0 - smoothstep(radius, radius * 1.15, distance(p, centre)));
	COLOR = vec4(mix(tint, vec3(1.0, 0.6, 0.25), edge * warmth * 0.22), 0.96 * (1.0 - lit));
}
