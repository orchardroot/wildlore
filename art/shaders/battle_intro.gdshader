shader_type canvas_item;
// Battle entry transitions (see BattleIntro). `amount` runs 0 (clear) to 1 (fully covered in `ink`, the colour of
// Router's fade, so the hand-over is seamless).
// mode 0 grass: blades sweep in from the left. 1 ripple: rings spread from the player. 2 iris: a circle closes
// on the player. 3 bars: diagonal bars slide in from alternate sides. 4 pulse: a slow dark pulse (the legends).
uniform int mode = 0;
uniform float amount = 0.0;
uniform vec2 centre = vec2(0.5, 0.55);   // UV
uniform float aspect = 1.7778;
uniform vec3 ink : source_color = vec3(0.03, 0.03, 0.05);

float hash(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float a = clamp(amount, 0.0, 1.0);
	float d = length((uv - centre) * vec2(aspect, 1.0));
	float maxd = length(vec2(aspect, 1.0));
	float cov = 0.0;
	vec3 col = ink;
	float to_ink = smoothstep(0.6, 1.0, a);
	if (mode == 0) {
		float cols = 56.0;
		float id = floor(uv.x * cols);
		float h = hash(id);
		float blade = abs(fract(uv.x * cols) - 0.5) * 2.0;
		float grown = clamp((a * 1.6 - uv.x * 0.6 - h * 0.15) * 1.6, 0.0, 1.3);
		cov = step(1.0 - uv.y, grown - blade * 0.12);
		vec3 green = vec3(0.16, 0.32, 0.14) * (0.65 + 0.6 * h) * (0.7 + 0.3 * (1.0 - blade));
		col = mix(green, ink, to_ink);
	} else if (mode == 1) {
		float r = a * maxd * 1.15;
		float wob = sin(d * 60.0 - a * 30.0) * 0.02;
		cov = step(d, r + wob);
		float ring = step(fract(d * 12.0 - a * 5.0), 0.12) * (1.0 - to_ink);
		col = mix(mix(vec3(0.07, 0.17, 0.3), ink, to_ink), vec3(0.35, 0.55, 0.7), ring * 0.5);
	} else if (mode == 2) {
		cov = step((1.0 - a) * maxd, d);
	} else if (mode == 3) {
		float band = floor((uv.y + uv.x * 0.35) * 7.0);
		float along = mod(band, 2.0) < 1.0 ? uv.x : 1.0 - uv.x;
		cov = step(along, a * 1.25 - hash(band + 3.0) * 0.25);
		col = mix(mod(band, 2.0) < 1.0 ? vec3(0.1, 0.07, 0.09) : vec3(0.05, 0.05, 0.08), ink, to_ink);
	} else {
		float vign = smoothstep(0.3, 1.1, d / maxd * 1.6);
		cov = clamp(a + vign * 0.35 * a, 0.0, 1.0);
		col = mix(vec3(0.1, 0.04, 0.14), ink, to_ink);
	}
	COLOR = vec4(col, cov);
}
