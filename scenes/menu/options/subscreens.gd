extends Control

export var default_subscreen_path: NodePath
onready var current_subscreen: Node = get_node(default_subscreen_path)

export var buttons_container_path: NodePath
onready var buttons_container: VBoxContainer = get_node(buttons_container_path)

func _ready():
	toggle_button_appearance(true)


func toggle_button_appearance(selected: bool):
	var current_button = buttons_container.get_node(current_subscreen.name)
	current_button.force_hover = selected
	current_button.modulate = Color(1.35, 1.35, 1.35) if selected else Color.white

func change_subscreen(new_subscreen: String):
	toggle_button_appearance(false)
	current_subscreen.visible = false
	
	# it uses the same variable, but it's a different node
	current_subscreen = get_node(new_subscreen)
	current_subscreen.visible = true
	
	toggle_button_appearance(true)
