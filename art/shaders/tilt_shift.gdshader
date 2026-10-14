shader_type canvas_item;
// Tilt-shift: a sharp band through the middle of the screen, increasingly soft towards the top and bottom.
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float strength = 0.6;
uniform float centre = 0.56;
uniform float band = 0.22;

void fragment() {
	vec2 uv = SCREEN_UV;
	float amt = smoothstep(band, 0.55, abs(uv.y - centre)) * strength;
	vec2 px = SCREEN_PIXEL_SIZE * amt * 3.0;
	vec3 c = texture(screen_tex, uv).rgb * 0.2;
	c += texture(screen_tex, uv + vec2(px.x, 0.0)).rgb * 0.1;
	c += texture(screen_tex, uv - vec2(px.x, 0.0)).rgb * 0.1;
	c += texture(screen_tex, uv + vec2(0.0, px.y)).rgb * 0.1;
	c += texture(screen_tex, uv - vec2(0.0, px.y)).rgb * 0.1;
	c += texture(screen_tex, uv + px).rgb * 0.1;
	c += texture(screen_tex, uv - px).rgb * 0.1;
	c += texture(screen_tex, uv + vec2(px.x, -px.y)).rgb * 0.1;
	c += texture(screen_tex, uv + vec2(-px.x, px.y)).rgb * 0.1;
	COLOR = vec4(c, 1.0);
}
