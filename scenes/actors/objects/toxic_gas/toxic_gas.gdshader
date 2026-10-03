shader_type canvas_item;

uniform sampler2D tex1_texture;
uniform sampler2D tex2_texture;
uniform sampler2D distortion_texture;

uniform vec4 color : hint_color;

uniform vec2 position;
uniform vec2 size;
uniform vec2 offset;
uniform float rotation;

uniform vec2 tex1_offset;
uniform vec2 tex1_speed;

uniform vec2 tex2_offset;
uniform vec2 tex2_speed;

uniform vec2 distortion_offset;
uniform vec2 distortion_speed;

vec2 get_scale(ivec2 texture_size) {
	return size/vec2(texture_size);
}

vec2 transform_uv(vec2 uv, vec2 pivot, vec2 scale, float angle, vec2 translation) {
	// First we scale...
	uv -= pivot;
	uv *= scale;
	
	// Next we rotate...
	float cosine = cos(angle);
	float sine = sin(angle);
	uv = vec2(
		uv.x * cosine - uv.y * sine,
		uv.x * sine + uv.y * cosine
	);
	
	// Finally we undo the pivot and translate the UV! Simple :D
	uv += pivot + translation;
	return uv;
}

void fragment() {
	vec2 distortion_scale = get_scale(textureSize(distortion_texture, 0));
	vec2 tex1_scale = get_scale(textureSize(tex1_texture, 0));
	vec2 tex2_scale = get_scale(textureSize(tex2_texture, 0));
	
	vec2 offset_1 = (distortion_offset/vec2(textureSize(distortion_texture, 0))) + (distortion_speed * TIME);
	vec2 distortion_uv = transform_uv(UV, position / size, distortion_scale, rotation, offset_1 + (offset / vec2(textureSize(distortion_texture, 0))));
	vec4 distortion = texture(distortion_texture, distortion_uv);
	
	vec2 offset_2 = (tex1_offset/vec2(textureSize(tex1_texture, 0))) + (tex1_speed * TIME);
	vec2 tex1_uv = transform_uv(UV, position / size, tex1_scale, rotation, offset_2 + (offset / vec2(textureSize(tex1_texture, 0))));
	vec4 mask = texture(tex1_texture, tex1_uv);
	
	vec2 offset_3 = (tex2_offset/vec2(textureSize(tex2_texture, 0))) + (tex2_speed * TIME);
	vec2 tex2_uv = transform_uv(UV, position / size, tex2_scale, rotation, offset_3 + (offset / vec2(textureSize(tex2_texture, 0))));
	vec4 tex2 = texture(tex2_texture, tex2_uv);
	
	
	COLOR.rgb = (tex2.rgb * color.rgb);
	
//	COLOR.a = clamp((mask.r + .5) * .69, 0.0, 1.0)*color.a;
	COLOR.a = .8 * color.a;
}
	