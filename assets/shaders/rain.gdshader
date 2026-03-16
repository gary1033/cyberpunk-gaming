shader_type canvas_item;

uniform float rain_intensity : hint_range(0.0, 1.0) = 0.6;
uniform float rain_speed : hint_range(1.0, 20.0) = 8.0;
uniform float rain_angle : hint_range(-0.5, 0.5) = 0.1;
uniform vec4 rain_color : source_color = vec4(0.6, 0.7, 0.9, 0.3);
uniform float drop_length : hint_range(0.01, 0.1) = 0.04;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	vec4 base_color = texture(TEXTURE, uv);

	float rain = 0.0;

	// Multiple rain layers for depth
	for (int i = 0; i < 3; i++) {
		float layer = float(i);
		float speed = rain_speed * (1.0 + layer * 0.3);
		float scale = 20.0 + layer * 10.0;

		vec2 rain_uv = uv * scale;
		rain_uv.y += TIME * speed;
		rain_uv.x += rain_angle * TIME * speed;

		vec2 cell = floor(rain_uv);
		vec2 local = fract(rain_uv);

		float h = hash(cell);
		if (h > (1.0 - rain_intensity)) {
			float drop = smoothstep(0.0, drop_length, local.y) *
						 smoothstep(drop_length * 2.0, drop_length, local.y);
			drop *= smoothstep(0.3, 0.5, local.x) * smoothstep(0.7, 0.5, local.x);
			rain += drop * (0.5 + layer * 0.2);
		}
	}

	rain = clamp(rain, 0.0, 1.0);
	vec4 final_color = mix(base_color, rain_color, rain * rain_color.a);
	COLOR = final_color;
}
