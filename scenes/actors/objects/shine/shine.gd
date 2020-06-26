extends GameObject

onready var effects = $ShineEffects
onready var animated_sprite = $AnimatedSprite
onready var area = $Area2D
onready var sound = $CollectSound
var collected = false
var character

var anim_damp = 160

var title := "Unnamed Shine"
var description := "This is a shine! Collect it to win the level."
var show_in_menu := false
var activated := true
var activate_on := 0

onready var normal_frames = preload("res://scenes/actors/objects/shine/frames_normal.tres")
onready var deactivated_frames = preload("res://scenes/actors/objects/shine/frames_deactivated.tres")

func _set_properties():
	savable_properties = ["title", "description", "show_in_menu", "activated", "activate_on"]
	editable_properties = ["title", "description", "show_in_menu", "activated", "activate_on"]
	
func _set_property_values():
	set_property("title", title, true)
	set_property("description", description, true)
	set_property("show_in_menu", show_in_menu, true)
	set_property("activated", activated, true)
	set_property("activate_on", activate_on, true)

func collect(body):
	if activated and enabled and !collected and body.name.begins_with("Character") and body.controllable:
		character = body
		character.set_state_by_name("Fall", 0)
		character.velocity = Vector2(0, 0)
		character.get_node("Sprite").rotation_degrees = 0
		character.controllable = false
		#sound.play() -Sound doesn't carry over between scenes, so it cuts off
		collected = true
		visible = false

func _ready():
	if mode != 1:
		if activate_on != 0:
			activated = false
		var _connect = area.connect("body_entered", self, "collect")

func _physics_process(_delta):
	if activate_on == 1 and !activated:
		if CurrentLevelData.level_data.vars.red_coins_collected == CurrentLevelData.level_data.vars.max_red_coins:
			activated = true
	
	animated_sprite.frame = (OS.get_ticks_msec() / anim_damp) % 4
	if !collected:
		if !activated:
			animated_sprite.frame = 0
			animated_sprite.frames = deactivated_frames
			effects.visible = false
		else:
			animated_sprite.frames = normal_frames
			effects.visible = true
	effects.rotation_degrees = (OS.get_ticks_msec()/16) % 360
	if collected:
		var sprite = character.get_node("Sprite")
		sprite.animation = "shineFall"
		if character.is_grounded():
			character.exit()
