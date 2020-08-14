extends Screen

onready var tween = $Tween
onready var shine_parent = $ShineParent

const SHINE_SPRITE_SCENE = preload("res://scenes/menu/shine_select_screen/shine_sprite.tscn")
const CHANGE_SELECTION_TIME : float = 0.35

#
const SHINE_BESIDE_CENTER_POSITION : float = 125.0
const SHINE_BESIDE_BESIDE_CENTER_POSITION : float = SHINE_BESIDE_CENTER_POSITION + 100.0
# had to add two extra edge positions so it would look and feel right
const SHINE_BESIDE_EDGES_POSITION : float = SHINE_BESIDE_BESIDE_CENTER_POSITION + 100.0
const SHINE_AT_EDGES_POSITION : float = SHINE_BESIDE_EDGES_POSITION + 100.0

#
const SHINE_CENTER_SIZE : float = 4.0
const SHINE_BESIDE_CENTER_SIZE : float = 2.0
const SHINE_DEFAULT_SIZE : float = 2.0

var selected_shine : int = 0

var shine_sprites : Array = []
var shine_details : Array

func _open_screen() -> void:
	shine_details = SavedLevels.levels[SavedLevels.selected_level].shine_details

	for i in range(shine_details.size()):
		var shine_sprite = SHINE_SPRITE_SCENE.instance()
		shine_sprites.append(shine_sprite)
		# if the first shine, this will be 0 (no offset), if the second shine it'll be the beside center position
		# and if any shine after that (i > 1) it'll be the beside beside center position
		shine_sprite.position.x = SHINE_BESIDE_CENTER_POSITION * int(i == 1) + SHINE_BESIDE_BESIDE_CENTER_POSITION * int(i > 1)

		shine_parent.add_child(shine_sprite)
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_right"):
#		tween.interpolate_property(shine_parent, "position:x", null, shine_parent.position.x - SHINE_SEPARATION, \
#				CHANGE_SELECTION_TIME, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		 # the clamp basically just limits how far you can scroll
		selected_shine = clamp(selected_shine + 1, 0, shine_details.size() - 1)
	elif Input.is_action_just_pressed("ui_left"):
#		tween.interpolate_property(shine_parent, "position:x", null, shine_parent.position.x + SHINE_SEPARATION, \
#				CHANGE_SELECTION_TIME, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		selected_shine = clamp(selected_shine - 1, 0, shine_details.size() - 1)
	for i in range(shine_sprites.size()):
		var shine_size = SHINE_DEFAULT_SIZE
		var shine_transparency = max(0, 1 - abs(0.25 * (selected_shine - i)))
		var target_position_x : float
		if i == selected_shine:
			shine_size = SHINE_CENTER_SIZE
			target_position_x = 0 
		elif abs(i - selected_shine) == 1:
			shine_size = SHINE_BESIDE_CENTER_SIZE
			target_position_x = SHINE_BESIDE_CENTER_POSITION * sign(i - selected_shine)
		elif abs(i - selected_shine) == 2:
			target_position_x = SHINE_BESIDE_BESIDE_CENTER_POSITION * sign(i - selected_shine)
		elif abs(i - selected_shine) == 3:
			target_position_x = SHINE_BESIDE_EDGES_POSITION * sign(i - selected_shine)
		elif abs(i - selected_shine) > 3:
			target_position_x = SHINE_AT_EDGES_POSITION * sign(i - selected_shine)
		tween.interpolate_property(shine_sprites[i], "scale", null, Vector2(shine_size, shine_size), \
				CHANGE_SELECTION_TIME, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(shine_sprites[i], "position:x", null, target_position_x, \
				CHANGE_SELECTION_TIME, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(shine_sprites[i], "modulate:a", null, shine_transparency, \
				CHANGE_SELECTION_TIME, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
