extends EditorWindow

const TEXT: String = "[center]This action will place %d tiles. Are you sure?[/center]"

onready var description = $"%Description"

signal choice_made(choice)

func cancel():
	emit_signal("choice_made", false)
	close()

func confirm():
	emit_signal("choice_made", true)
	close()

func set_tile_number(num: int) -> void:
	description.bbcode_text = TEXT % num
