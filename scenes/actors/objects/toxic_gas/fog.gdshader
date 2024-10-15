shader_type canvas_item;
render_mode blend_add, unshaded;

uniform vec4 uv_main_tiling_offset_speed;
uniform vec4 uv_mask_tiling_offset_speed;
uniform vec4 uv_dissolve_tiling_offset_speed;

uniform sampler2D mask;
uniform sampler2D dissolve;
uniform float dissolve_value : hint_range(0,1);

varying vec2 main_tiling;
varying vec2 main_offset_speed;

varying vec2 mask_tiling;
varying vec2 mask_offset_speed;

varying vec2 dissolve_tiling;
varying vec2 dissolve_offset_speed;

const float PI = 3.1415926535897932;


void fragment() {
	main_tiling = uv_main_tiling_offset_speed.xy;
	main_offset_speed = uv_main_tiling_offset_speed.zw;
	mask_tiling = uv_mask_tiling_offset_speed.xy;
	mask_offset_speed = uv_mask_tiling_offset_speed.zw;
	dissolve_tiling = uv_dissolve_tiling_offset_speed.xy;
	dissolve_offset_speed = uv_dissolve_tiling_offset_speed.zw;
	
	vec2 main_uv = UV;
	vec2 mask_uv = UV;
	
	vec2 base_uv = UV;
	base_uv -= 0.5;
	base_uv *= 2.0;
	
	float angle = atan(base_uv.y, base_uv.x) / (2.0 * PI);
	float dist = sqrt((base_uv.x*base_uv.x)+(base_uv.y*base_uv.y));
			
	vec2 dissolve_polar_uv = vec2(
			angle,
			dist
			);
	
	vec2 main_offset = main_offset_speed * TIME;
	vec2 mask_offset = mask_offset_speed * TIME;
	vec2 dissolve_offset = dissolve_offset_speed * TIME;
	
	main_uv *= main_tiling;
	main_uv += main_offset;

	mask_uv *= mask_tiling;
	mask_uv += mask_offset;
	
	base_uv *= dissolve_tiling;
	base_uv += dissolve_offset;
	
	COLOR = texture(TEXTURE, main_uv);
	COLOR.a *= texture(mask, mask_uv).r/2.0;
//	COLOR = vec4(mod(COLOR.r, .005)*100.0, mod(COLOR.g, .005)*100.0, mod(COLOR.b, .005)*100.0, COLOR.a);
}
