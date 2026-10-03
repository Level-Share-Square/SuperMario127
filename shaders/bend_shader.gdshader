shader_type canvas_item;

uniform float strength = 0.0;
uniform vec2 center = vec2(0.5);
uniform float color_curve : hint_range(0.1, 10.0) = 10.0;

void fragment() {
	vec2 new_uv = UV - center;
	float angle = strength * new_uv.y;
	
	mat2 rotation_matrix = mat2(
		vec2( cos(angle), -sin(angle) ),
		vec2( sin(angle),  cos(angle) )
	);
	
	new_uv = rotation_matrix * new_uv + center;
	
	vec4 tex_color = texture(TEXTURE, new_uv);

	float brightness = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	float modulate_strength = 1.0 - pow(clamp(brightness, 0.0, 1.0), color_curve);
	vec3 final_modulate_rgb = mix(vec3(1.0), MODULATE.rgb, modulate_strength);

	COLOR = tex_color * vec4(final_modulate_rgb, MODULATE.a);
}