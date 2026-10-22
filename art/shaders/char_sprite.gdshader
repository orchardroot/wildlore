shader_type spatial;
render_mode cull_disabled, specular_disabled, depth_draw_opaque;
// Medium and High graphics: a character billboard (CharSprite, Y-fixed like BILLBOARD_FIXED_Y) that stays
// readable. Lit like the world, but it never sinks below a share of its own colour (`lift`), so people and
// creatures stand out in a building's shadow, a dim room or at night; and the side facing away from the sun gets
// a faint cool rim. Low uses the plain sprite material instead.
uniform sampler2D tex : source_color, filter_nearest;
uniform float lift = 0.22;
uniform vec3 rim_colour : source_color = vec3(0.75, 0.85, 1.0);
uniform float rim = 0.12;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0),
		vec4(0.0, 1.0, 0.0, 0.0),
		vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0),
		MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
		vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
		vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
		vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
		vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec4 c = texture(tex, UV) * COLOR;
	ALBEDO = c.rgb;
	ALPHA = c.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	// the sprite's edge pixels (opaque, next to a transparent one) catch the rim light
	vec2 px = 1.0 / vec2(textureSize(tex, 0));
	float open = 1.0 - min(min(texture(tex, UV + vec2(px.x, 0.0)).a, texture(tex, UV - vec2(px.x, 0.0)).a),
		min(texture(tex, UV + vec2(0.0, px.y)).a, texture(tex, UV - vec2(0.0, px.y)).a));
	EMISSION = c.rgb * lift + rim_colour * rim * open;
	ROUGHNESS = 1.0;
}
