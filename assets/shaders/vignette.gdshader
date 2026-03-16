shader_type canvas_item;

uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float vignette_radius : hint_range(0.0, 1.0) = 0.7;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.4;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec2 center = UV - vec2(0.5);
	float dist = length(center);
	float vignette = smoothstep(vignette_radius, vignette_radius - vignette_softness, dist);
	tex_color.rgb = mix(vignette_color.rgb, tex_color.rgb, mix(1.0, vignette, vignette_intensity));
	COLOR = tex_color;
}
