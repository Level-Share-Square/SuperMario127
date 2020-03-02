extends TextureButton

var layer_0_text = "Layer\n     0"
var layer_1_text = "Layer\n     1"
var layer_2_text = "Layer\n     2"

func _process(delta):
	var tilemap_node = get_node("../../../TileMap")
	var text = get_node("RichTextLabel")
	if tilemap_node.layer == 0:
		text.bbcode_text = layer_0_text
	elif tilemap_node.layer == 1:
		text.bbcode_text = layer_1_text
	elif tilemap_node.layer == 2:
		text.bbcode_text = layer_2_text

func _pressed():
	var tilemap_node = get_node("../../../TileMap")
	tilemap_node.switch_layers()
