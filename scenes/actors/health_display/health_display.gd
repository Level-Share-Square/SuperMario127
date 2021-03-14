extends Node2D
 
export var char_path : NodePath
var character : Character

onready var ui = $CanvasLayer/HealthUI
onready var ui_shadow = $CanvasLayer/HealthUI/Shadow
onready var juice = $CanvasLayer/HealthUI/Juice
onready var label = $CanvasLayer/HealthUI/Label
onready var tween = $CanvasLayer/HealthUI/Tween

var interpolation_speed = 15

var shown = false
var last_shown = false
var water_height = 0

export var material_0 : ShaderMaterial
export var material_1 : ShaderMaterial

export var four_quarter_color : Color
export var three_quarter_color : Color
export var two_quarter_color : Color
export var one_quarter_color : Color

var current_health = 8

# The code I added to make the new UI work is not very well done, but
# it would be a waste of time and effort to try to clean it up as I would 
# have to rewrite the whole script, none of this is well made code.

# And that wouldn't make much of a difference, the whole game is 
# being rewritten already. I doubt anyone would need to work much
# with this code between now, and after the rewrite is finished.

func _ready():
	character = get_node(char_path)
	if (character.player_id == 0) and Singleton.PlayerSettings.number_of_players == 2 and Singleton.PlayerSettings.other_player_id == -1:
		ui.rect_position.x = 309
	elif (character.player_id == 1) and Singleton.PlayerSettings.number_of_players == 2 and Singleton.PlayerSettings.other_player_id == -1:
		ui.rect_position.x = 693
	else:
		ui.rect_position.x = 693
		
	if character.player_id == 0:
		juice.material = material_0
	else:
		juice.material = material_1
	
	yield(get_tree().create_timer(1), "timeout")

func _process(delta):
	if is_instance_valid(character):
		if character is Character:
			if character.health < 8:
				shown = true
			else:
				shown = false
				
			label.text = str(character.health)
			
			water_height = lerp(water_height, 1 - (float(wrapi(character.health_shards, 0, 5)) / 4), delta * 4)
			juice.material.set_shader_param("water_height", water_height)
			
			if character.health != current_health:
				var color_to_use
				
				# i would think up a better solution but again waste of effort
				if character.health > 6:
					color_to_use = four_quarter_color
				elif character.health > 4:
					color_to_use = three_quarter_color
				elif character.health > 2:
					color_to_use = two_quarter_color
				elif character.health >= 0:
					color_to_use = one_quarter_color
				
				tween.interpolate_property(ui, "tint_progress",
					ui.tint_progress, color_to_use, 0.65,
					Tween.TRANS_CUBIC, Tween.EASE_OUT)
				tween.interpolate_property(ui, "value",
					(12.5 * current_health), (12.5 * character.health), 0.65,
					Tween.TRANS_CUBIC, Tween.EASE_OUT)
					
				tween.start()
				
				current_health = character.health
			#shards.region_rect = Rect2(Vector2(character.health_shards * 256, 0), Vector2(256, 96))
	else:
		shown = false
		
	if shown and !last_shown:
		tween.interpolate_property(ui, "rect_position",
			ui.rect_position, Vector2(ui.rect_position.x, 15), 0.50,
			Tween.TRANS_BACK, Tween.EASE_OUT)
		tween.start()
	elif !shown and last_shown:
		tween.interpolate_property(ui, "rect_position",
			ui.rect_position, Vector2(ui.rect_position.x, -60), 0.50,
			Tween.TRANS_BACK, Tween.EASE_IN)
		tween.start()
	
	last_shown = shown
	
	if Singleton.PhotoMode.enabled:
		ui.visible = false
	else:
		ui.visible = true
