extends Screen

onready var tween = $Tween
onready var shine_parent = $ShineParent

onready var level_title = $Labels/LevelTitle
onready var shine_title = $Labels/ShineTitle
onready var shine_description = $Labels/ShineDescription

onready var button_move_left = $Buttons/ButtonMoveLeft 
onready var button_move_right = $Buttons/ButtonMoveRight 
onready var button_select_shine = $Buttons/ButtonSelectShine 
onready var button_back = $Buttons/ButtonBack

const SHINE_SPRITE_SCENE = preload("res://scenes/menu/shine_select_screen/shine_sprite.tscn")
const CHANGE_SELECTION_TIME : float = 0.35

# spacing between the shines at different points
const SHINE_BESIDE_CENTER_POSITION : float = 125.0
const SHINE_BESIDE_BESIDE_CENTER_POSITION : float = SHINE_BESIDE_CENTER_POSITION + 100.0
# had to add two extra edge positions so it would look and feel right
const SHINE_BESIDE_EDGES_POSITION : float = SHINE_BESIDE_BESIDE_CENTER_POSITION + 100.0
const SHINE_AT_EDGES_POSITION : float = SHINE_BESIDE_EDGES_POSITION + 100.0

# size of the shine at different points
const SHINE_CENTER_SIZE : float = 4.0
const SHINE_BESIDE_CENTER_SIZE : float = 2.0
const SHINE_DEFAULT_SIZE : float = 2.0

var selected_shine : int = 0

# array of all the ShineSprite scene instances used to make the shine select screen work
var shine_sprites : Array = []
# contains an array that stores dictionaries containing all the information needed to populate the shine select screen
var shine_details : Array

func _ready() -> void:
	var _connect 
	_connect = button_move_left.connect("pressed", self, "on_button_move_left_pressed")
	_connect = button_move_right.connect("pressed", self, "on_button_move_right_pressed")
	_connect = button_select_shine.connect("pressed", self, "on_button_select_shine_pressed")
	_connect = button_back.connect("pressed", self, "on_button_back_pressed")

func _open_screen() -> void:
	shine_details = SavedLevels.levels[SavedLevels.selected_level].shine_details

	for i in range(shine_details.size()):
		var shine_sprite = SHINE_SPRITE_SCENE.instance()
		shine_sprites.append(shine_sprite)
		# if the first shine, this will be 0 (no offset), if the second shine it'll be the beside center position
		# and if any shine after that (i > 1) it'll be the beside beside center position
		shine_sprite.position.x = SHINE_BESIDE_CENTER_POSITION * int(i == 1) + SHINE_BESIDE_BESIDE_CENTER_POSITION * int(i > 1)

		shine_parent.add_child(shine_sprite)

	move_shine_sprites() # make sure everything is in the right spot and size and such
	update_labels()
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_right"):
		attempt_increment_selected_shine(1)
	elif Input.is_action_just_pressed("ui_left"):
		attempt_increment_selected_shine(-1)

# this will try to change the selected shine, but won't if you're already at the first or last shine
func attempt_increment_selected_shine(increment : int) -> void:
	var previous_selected_shine = selected_shine
	# warning-ignore: narrowing_conversion
	selected_shine = clamp(selected_shine + increment, 0, shine_sprites.size() - 1)

	# no point in doing anything if the value didn't actually change
	if selected_shine == previous_selected_shine:
		return

	move_shine_sprites()
	update_labels()

func move_shine_sprites() -> void:
	for i in range(shine_sprites.size()):
		var shine_size = SHINE_DEFAULT_SIZE
		# middle shine is opaque, next is 0.75 alpha, after that is 0.5, etc
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

func update_labels() -> void:
	# this will assume the selected shine and the selected level are valid
	level_title.text = SavedLevels.levels[SavedLevels.selected_level].level_name
	shine_title.text = shine_details[selected_shine]["title"]
	shine_description.text = shine_details[selected_shine]["description"]

# signal responses start here 

func on_button_move_left_pressed() -> void:
	attempt_increment_selected_shine(-1)

func on_button_move_right_pressed() -> void:
	attempt_increment_selected_shine(1)

func on_button_select_shine_pressed() -> void:
	pass 

func on_button_back_pressed() -> void:
	emit_signal("screen_change", "shine_select_screen", "levels_screen")

