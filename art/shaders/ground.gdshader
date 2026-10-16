shader_type spatial;
// The zone's ground: vertex colour like the solid material, plus weather. Vertex alpha 0 marks hard
// surfaces (roads, cobbles, platforms) that darken and shine when `wet`; `frost` rimes the flat tops.
uniform float wet = 0.0;
uniform float frost = 0.0;

varying float up;

void vertex() {
	up = (MODEL_MATRIX * vec4(NORMAL, 0.0)).y;
}

void fragment() {
	vec3 c = COLOR.rgb;  // vertex colours arrive linear here, as the solid material sees them
	float hard = 1.0 - COLOR.a;
	float level = smoothstep(0.6, 0.95, up);
	c *= 1.0 - wet * (0.12 + 0.24 * hard);
	c = mix(c, vec3(0.6, 0.66, 0.74), frost * level * (0.38 - 0.14 * hard));
	ALBEDO = c;
	ROUGHNESS = mix(1.0, 0.32, wet * hard);
	SPECULAR = 0.55 * wet * hard;
}
