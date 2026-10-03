extends Control


func _make_custom_tooltip(for_text: String):
	var label = Label.new()
	label.text = for_text
	label.theme_type_variation = "ShineTooltip"
	return label
