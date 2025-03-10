shader_type canvas_item;

uniform sampler2D tex1_texture;
uniform sampler2D tex2_texture;
uniform sampler2D distortion_texture;

uniform vec4 color : hint_color;

uniform vec4 tex1_scale_speed;
uniform vec4 tex2_scale_speed;
uniform vec4 distortion_scale_speed;

void fragment() {
	vec4 distortion = texture(distortion_texture, (UV*distortion_scale_speed.xy)+(TIME*distortion_scale_speed.zw));
	vec4 mask = texture(tex1_texture, (UV*tex1_scale_speed.xy)+(TIME*tex1_scale_speed.zw));
	vec4 tex2 = texture(tex2_texture, (UV*tex2_scale_speed.xy)+(TIME*tex2_scale_speed.zw));
	
	COLOR.rgb = (tex2.rgb * color.rgb);
	
	COLOR.a = clamp(mask.r, 0.0, 1.0)*color.a;
}
	