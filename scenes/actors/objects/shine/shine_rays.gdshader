shader_type canvas_item;
render_mode blend_add;

const float PI = 3.1415926535897932384626433832795;

uniform int ray_count = 4;
uniform float ray_distance = 0.5;
uniform float ray_seperation_degrees = 20.0;
uniform float rotation = 0.0;

void fragment() {
	vec2 new_uv = UV - vec2(0.5);
	float angle = atan(new_uv.y, new_uv.x) - rotation;
	float radius = length(new_uv);
	
	float ray_size = radians(360.0 * (1.0/float(ray_count)));
	float gap = radians(ray_seperation_degrees);
	
	int ray = int(angle / ray_size);
	
	float local_angle = mod(angle, ray_size);
	
	float cutoff = ray_distance;
	
	if (radius > cutoff || local_angle < gap || local_angle > (ray_size - gap)) {
		discard;
	}
	
	COLOR = vec4(COLOR.rgb, COLOR.a * (ray_distance-radius));
}
