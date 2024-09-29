shader_type canvas_item;
render_mode unshaded;

uniform bool Smooth = true;
uniform float width : hint_range(0.0, 16) = 1.0;
uniform vec4 outline_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform int pixel_size : hint_range(1, 10) = 4;

void fragment()
{
	vec2 unit = (1.0/float(pixel_size) ) / vec2(textureSize(TEXTURE, 0));
	vec4 pixel_color = texture(TEXTURE, UV);
	if (pixel_color.a == 0.0) {
		pixel_color = outline_color/pixel_color;
		pixel_color.a = 0.0;
		for (float x = -ceil(width); x <= ceil(width); x++) {
			for (float y = -ceil(width); y <= ceil(width); y++) {
				if (texture(TEXTURE, UV + vec2(x*unit.x, y*unit.y)).a == 0.0 || (x==0.0 && y==0.0)) {
					continue;
				}
				if (Smooth) {
					pixel_color.a += outline_color.a / (pow(x,2)+pow(y,2)) * (1.0-pow(2.0, -width));
					if (pixel_color.a > 1.0) {
						pixel_color.a = 1.0;
					}
				} else {
					pixel_color.a = outline_color.a;
					break;
				}
			}
		}
	}
	COLOR = pixel_color;
}
