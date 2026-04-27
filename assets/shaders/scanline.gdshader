shader_type canvas_item;

uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.08;
uniform float scanline_frequency : hint_range(1.0, 500.0) = 200.0;
uniform float flicker_speed : hint_range(0.0, 10.0) = 2.0;
uniform vec4 tint_color : source_color = vec4(0.0, 0.9, 0.9, 0.12);

void fragment() {
	vec2 uv = SCREEN_UV;

	float scanline = 0.5 + 0.5 * sin(uv.y * scanline_frequency * 3.14159);
	float flicker = sin(TIME * flicker_speed) * 0.02 + 0.98;
	float alpha = (tint_color.a + scanline * scanline_intensity) * flicker;
	COLOR = vec4(tint_color.rgb, alpha);
}
