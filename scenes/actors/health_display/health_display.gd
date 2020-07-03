extends Node2D
 
export var char_path : NodePath
var character : Character

onready var ui = $CanvasLayer/HealthUI
onready var shards = $CanvasLayer/HealthUI/TextureRect
onready var label = $CanvasLayer/HealthUI/Label
onready var label_shadow = $CanvasLayer/HealthUI/LabelShadow
onready var tween = $CanvasLayer/HealthUI/Tween

var interpolation_speed = 15

var shown = false
var last_shown = false

export var atlas_0 : AtlasTexture
export var atlas_1 : AtlasTexture

export var shard_atlas_0 : AtlasTexture
export var shard_atlas_1 : AtlasTexture

func _ready():
	character = get_node(char_path)
	if (character.player_id == 0) and PlayerSettings.number_of_players == 2 and PlayerSettings.other_player_id == -1:
		ui.rect_position.x = 160
	elif (character.player_id == 1) and PlayerSettings.number_of_players == 2 and PlayerSettings.other_player_id == -1:
		ui.rect_position.x = 544
	else:
		ui.rect_position.x = 352
		
	if character.player_id == 0:
		ui.texture = atlas_0
		shards.texture = shard_atlas_0
	else:
		ui.texture = atlas_1
		shards.texture = shard_atlas_1
		

func _process(delta):
	if is_instance_valid(character):
		if character.has_method("is_character"): # pro gamer move
			if character.health < 8:
				shown = true
			else:
				shown = false
				
			label.text = str(character.health)
			label_shadow.text = label.text
			var pos_x = ((8 - character.health) % 2) * 256
			var pos_y = 268 * floor((8 - character.health) / 2)
			ui.texture.region = Rect2(Vector2(pos_x, pos_y), Vector2(256, 268))
			shards.texture.region = Rect2(Vector2(character.health_shards * 256, 0), Vector2(256, 96))
	else:
		shown = false
		
	if shown and !last_shown:
		tween.interpolate_property(ui, "rect_position",
			ui.rect_position, Vector2(ui.rect_position.x, 20), 0.50,
			Tween.TRANS_BACK, Tween.EASE_OUT)
		tween.start()
	elif !shown and last_shown:
		tween.interpolate_property(ui, "rect_position",
			ui.rect_position, Vector2(ui.rect_position.x, -80), 0.50,
			Tween.TRANS_BACK, Tween.EASE_IN)
		tween.start()
	
	last_shown = shown
	
	if PhotoMode.enabled:
		ui.visible = false
	else:
		ui.visible = true
