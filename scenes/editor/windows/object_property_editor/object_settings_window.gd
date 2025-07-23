extends EditorWindow


var game_object: GameObject = GameObject.new()

onready var property_groups: PropertyEditorLoader = $"%PropertyGroups"


func _ready():
	var data = ObjectData.new()
	data.properties = [Vector2(0, 0), Vector2(1, 1), 0.0, true, true, 3, PoolStringArray([])]
	data.property_hints = [
		PropertyHints.new("Position", "base", "misc", "", []),
		PropertyHints.new("Scale", "base", "misc", "", []),
		PropertyHints.new("Rotation", "base", "misc", "", []),
		PropertyHints.new("Visible", "button", "misc", "", []),
		PropertyHints.new("Enabled", "button", "misc", "", []),
		PropertyHints.new("Layer", "dropdown", "misc", "", []),
		PropertyHints.new("Dialogue", "dialogue", "dialogue", "", []),
	]
	
	load_object(data)


func load_object(data: ObjectData):
	property_groups.load_property_editors(game_object, data)
