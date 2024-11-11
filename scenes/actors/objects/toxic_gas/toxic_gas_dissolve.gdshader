shader_type canvas_item;
render_mode blend_add, unshaded;

uniform vec2 scale;

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
	
	vec2 dissolve_uv = UV;
	dissolve_uv -= 0.5;
	dissolve_uv *= 2.0;
	
	
	vec2 main_offset = main_offset_speed * TIME;
	vec2 mask_offset = mask_offset_speed * TIME;
	vec2 dissolve_offset = dissolve_offset_speed * TIME;
	
	main_uv *= main_tiling;
	main_uv += main_offset;

	mask_uv *= mask_tiling;
	mask_uv += mask_offset;
	
//	dissolve_uv *= dissolve_tiling * scale;
//	dissolve_uv += dissolve_offset;
	
	COLOR = texture(TEXTURE, main_uv);
//	COLOR.rgb = mod(COLOR.rgb, vec3(.1))*vec3(10.0);
	COLOR.a *= texture(mask, mask_uv).r/2.0;
	if (abs(dissolve_uv.x) >= .75 * dissolve_tiling.x * scale.x) {
		float new_alpha = clamp((dissolve_value -  5.0 * (abs(dissolve_uv.x) - (.75 * dissolve_tiling.x * scale.x)) + min(1, texture(dissolve, dissolve_uv).x)), 0, 1);
//		new_alpha -= mod(new_alpha, .25)*4.0;
		COLOR.a *= new_alpha;
	}
	if (abs(dissolve_uv.y) >= .75 * dissolve_tiling.y * scale.y) {
		float new_alpha = clamp((dissolve_value - 5.0 * (abs(dissolve_uv.y) - (.75 * dissolve_tiling.y * scale.y)) + min(1, texture(dissolve, dissolve_uv).x)), 0, 1);
//		new_alpha -= mod(new_alpha, .25)*4.0;
		COLOR.a *= new_alpha;
	}
}
