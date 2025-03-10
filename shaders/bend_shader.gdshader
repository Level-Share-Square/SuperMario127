shader_type canvas_item;

uniform float strength = 0.0;
uniform vec2 center = vec2(0.5);

void fragment() {
	vec2 new_uv = UV - center;
	float angle = strength * new_uv.y;
	
	mat2 rotation_matrix = mat2(
		vec2( cos(angle), -sin(angle) ),
		vec2( sin(angle),  cos(angle) )
	);
	
	new_uv = rotation_matrix * new_uv + center;
	COLOR = texture(TEXTURE, new_uv);
}