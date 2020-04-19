extends Node2D
 
export var char_path : NodePath
var character : Character

onready var ui = $CanvasLayer/FluddUI
onready var stamina_display = $CanvasLayer/FluddUI/Stamina
onready var label = $CanvasLayer/FluddUI/Label
onready var label_shadow = $CanvasLayer/FluddUI/LabelShadow
onready var water_texture = $CanvasLayer/FluddUI/WaterTexture

var interpolation_speed = 15

export var material_0 : ShaderMaterial
export var material_1 : ShaderMaterial

func _ready():
	character = get_node(char_path)
	if (character.player_id == 0) and PlayerSettings.number_of_players == 2 and PlayerSettings.other_player_id == -1:
		ui.rect_position.x = 291
	else:
		ui.rect_position.x = 683
		
	if character.player_id == 0:
		water_texture.material = material_0
	else:
		water_texture.material = material_1

func _process(delta):
	if is_instance_valid(character):
		stamina_display.value = character.stamina
		label.text = str(int(character.fuel)) + "%"
		label_shadow.text = label.text
		
		var water_height = water_texture.material.get_shader_param("water_height")
		water_height = lerp(water_height, 1.0 - (character.fuel / 100), delta * interpolation_speed)
		water_texture.material.set_shader_param("water_height", water_height)
		ui.visible = character.nozzle != null and !PhotoMode.enabled
	else:
		ui.visible = false
