shader_type spatial;
render_mode cull_disabled, specular_disabled;
// Vertex-coloured foliage that sways in the wind. Higher vertices move more.
uniform float wind_strength = 0.035;
uniform float wind_speed = 1.3;
// The season from the real date (Seasonal.tint), each 0..1. Only leafy canopy changes: trunks, bark and low
// tufts keep their paint, and conifers (cool greens) stay evergreen apart from the frost.
uniform float spring = 0.0;  // blossom on some trees
uniform float autumn = 0.0;  // golds, oranges and russets
uniform float winter = 0.0;  // bare, browned canopy with rime on the tops
varying flat float v_tree;   // per tree (instance), 0..1
varying flat float v_face;   // per facet, 0..1
varying float v_canopy;      // 0 at the trunk and low tufts, 1 up in the leaves
varying float v_up;          // how much the facet faces the sky

vec3 to_linear(vec3 c) {
	return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c));
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_tree = hash(floor(MODEL_MATRIX[3].xz * 4.0));
	v_face = hash(floor(world.xz * 9.0) + vec2(floor(VERTEX.y * 9.0)));
	v_canopy = smoothstep(0.55, 1.05, VERTEX.y);
	v_up = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz).y;
	float w = max(VERTEX.y, 0.0);
	float sway = sin(TIME * wind_speed + world.x * 0.7 + world.z * 0.45) * wind_strength * w;
	sway += sin(TIME * wind_speed * 2.3 + world.z * 1.3) * wind_strength * 0.35 * w;
	VERTEX.x += sway;
	VERTEX.z += sway * 0.5;
}

vec3 seasonal(vec3 c) {
	// leafiness: green over red and blue; broadleaf: warmer (redder) than the blue-green pines
	float leafy = clamp((c.g - max(c.r, c.b)) * 7.0, 0.0, 1.0) * v_canopy;
	float broad = smoothstep(-0.01, 0.05, c.r - c.b);
	float lum = dot(c, vec3(0.3, 0.55, 0.15));
	if (autumn > 0.0) {
		// each tree picks its colour (a few hang on to their green); facets mottle between neighbouring shades
		float pick = fract(v_tree * 3.0 + v_face * 0.45);
		vec3 tone = vec3(0.86, 0.64, 0.22);                       // gold
		tone = mix(tone, vec3(0.82, 0.44, 0.16), step(0.33, pick)); // orange
		tone = mix(tone, vec3(0.63, 0.28, 0.15), step(0.66, pick)); // russet
		tone *= 0.75 + lum * 0.9;
		float keep_green = step(0.82, v_tree) * 0.6;
		c = mix(c, tone, leafy * broad * autumn * (1.0 - keep_green));
	}
	if (spring > 0.0) {
		// a third of the broadleaf trees in blossom, speckled over their facets
		float in_bloom = step(0.66, v_tree) * step(0.4, v_face);
		vec3 bloom = mix(vec3(0.96, 0.74, 0.82), vec3(0.97, 0.94, 0.92), step(0.75, v_face));
		c = mix(c, bloom * (0.7 + lum * 0.6), leafy * broad * in_bloom * spring * 0.9);
	}
	if (winter > 0.0) {
		vec3 bare = vec3(0.42, 0.36, 0.30) * (0.8 + lum * 0.6);
		c = mix(c, bare, leafy * broad * winter * 0.75);
		float rime = smoothstep(0.35, 0.85, v_up) * v_canopy;
		c = mix(c, vec3(0.86, 0.9, 0.95), rime * winter * 0.55);
	}
	return c;
}

void fragment() {
	// like the solid material's vertex_color_is_srgb: convert only when the output is linear (the Compatibility
	// renderer works in sRGB, so there the colour is used as written)
	vec3 c = seasonal(COLOR.rgb);
	ALBEDO = OUTPUT_IS_SRGB ? c : to_linear(c);
	ROUGHNESS = 1.0;
}
