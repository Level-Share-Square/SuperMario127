shader_type canvas_item;
uniform float color_curve : hint_range(0.1, 10.0) = 10.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	float brightness = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	float modulate_strength = 1.0 - pow(clamp(brightness, 0.0, 1.0), color_curve);
	vec3 final_modulate_rgb = mix(vec3(1.0), MODULATE.rgb, modulate_strength);

	COLOR = tex_color * vec4(final_modulate_rgb, MODULATE.a);
}