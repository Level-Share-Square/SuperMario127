tool extends RichTextEffect

var bbcode = "ghost"

func _process_custom_fx(char_fx):
	
	var speed = char_fx.env["freq"] if char_fx.env.has("freq") and \
									typeof(char_fx.env["freq"]) == TYPE_REAL \
									else 5.0
									
	var span = char_fx.env["span"] if char_fx.env.has("span") and \
									typeof(char_fx.env["span"]) == TYPE_REAL \
									else 10.0
	
	var alpha = sin(char_fx.elapsed_time * speed + (char_fx.absolute_index / span)) * 0.5 + 0.5
	char_fx.color.a = alpha
	return true;
