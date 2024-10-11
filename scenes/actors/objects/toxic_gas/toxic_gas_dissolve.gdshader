shader_type canvas_item;
render_mode blend_add, unshaded;

uniform vec4 uv_tiling_offset_speed;

uniform sampler2D mask;
uniform sampler2D dissolve;

varying vec2 tiling;
varying vec2 offset_speed;

const float PI = 3.1415926535897932;


void fragment() {
	tiling = uv_tiling_offset_speed.xy;
	offset_speed = uv_tiling_offset_speed.zw;
	
	vec2 base_uv = UV;
	base_uv -= 0.5;
	base_uv *= 2.0;
	
	float angle = atan(base_uv.y, base_uv.x) / (2.0 * PI);
	float dist = sqrt((base_uv.x*base_uv.x)+(base_uv.y*base_uv.y));
			
	vec2 polar_uv = vec2(
			angle,
			dist
			);
	
	vec2 offset = offset_speed * TIME;
	
	polar_uv *= tiling;
	polar_uv += offset;
	
	COLOR.a *= texture(mask, polar_uv).r;
}
