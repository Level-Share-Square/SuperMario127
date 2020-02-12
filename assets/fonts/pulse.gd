tool extends RichTextEffect

var bbcode = "pulse"

func _process_custom_fx(char_fx):
	var color = char_fx.env["color"] if char_fx.env.has("color") and \
								 typeof(char_fx.env["color"]) == TYPE_COLOR \
								 else char_fx.color
	var height = char_fx.env["height"] if char_fx.env.has("height") and\
								 typeof(char_fx.env["height"]) == TYPE_REAL \
								 else 0.0
	var freq = char_fx.env["freq"] if char_fx.env.has("freq") and\
								 typeof(char_fx.env["freq"]) == TYPE_REAL \
								 else 1.0
	
	var sinedTime = (sin(char_fx.elapsed_time * freq) + 1.0) / 2.0
	var y_off = sinedTime * height
	color.a = 1.0
	char_fx.color = char_fx.color.linear_interpolate(color, sinedTime)
	char_fx.offset = Vector2(0, -1) * y_off
	return true
