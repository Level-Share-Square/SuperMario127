shader_type canvas_item;

uniform float effectiveness : hint_range(0.0, 1.0, 0.1) = 0.0;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);

	vec3 white = vec3(1.0);
	original_color.rgb = mix(original_color.rgb, white, effectiveness);

	COLOR = original_color;
}
