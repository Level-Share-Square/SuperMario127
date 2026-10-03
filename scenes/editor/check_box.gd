extends TextureRect


export var checked: Texture
export var unchecked: Texture


func _toggle(value: bool):
	if value:
		texture = checked
	else:
		texture = unchecked
