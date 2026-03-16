shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 0.9, 0.9, 1.0);
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;
uniform float pulse_min : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Pulsating glow
	float pulse = mix(pulse_min, 1.0, (sin(TIME * pulse_speed) + 1.0) * 0.5);

	// Apply glow to non-transparent pixels
	if (tex_color.a > 0.1) {
		vec3 glow = glow_color.rgb * glow_intensity * pulse;
		tex_color.rgb = mix(tex_color.rgb, glow, 0.5);
	}

	COLOR = tex_color;
}
