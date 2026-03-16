shader_type canvas_item;

uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.15;
uniform float scanline_frequency : hint_range(1.0, 500.0) = 200.0;
uniform float flicker_speed : hint_range(0.0, 10.0) = 2.0;
uniform float distortion : hint_range(0.0, 0.01) = 0.002;
uniform vec4 tint_color : source_color = vec4(0.0, 0.9, 0.9, 0.1);

void fragment() {
	vec2 uv = SCREEN_UV;

	// Scanline effect
	float scanline = sin(uv.y * scanline_frequency * 3.14159) * scanline_intensity;

	// Subtle flicker
	float flicker = sin(TIME * flicker_speed) * 0.02 + 0.98;

	// Chromatic aberration / distortion
	float dist = distortion * sin(TIME * 1.5);
	vec4 color = vec4(0.0);
	color.r = texture(TEXTURE, uv + vec2(dist, 0.0)).r;
	color.g = texture(TEXTURE, uv).g;
	color.b = texture(TEXTURE, uv - vec2(dist, 0.0)).b;
	color.a = texture(TEXTURE, uv).a;

	// Apply effects
	color.rgb *= (1.0 - scanline) * flicker;

	// Cyan tint overlay
	color.rgb = mix(color.rgb, tint_color.rgb, tint_color.a);

	COLOR = color;
}
