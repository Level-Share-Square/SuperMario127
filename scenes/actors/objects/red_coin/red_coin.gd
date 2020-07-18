extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var sound = $AudioStreamPlayer
onready var last_sound = $LastCollect
onready var area = $Area2D
onready var visibility_enabler = $VisibilityEnabler2D
onready var label = $Label
onready var effects = $GlowEffects

var collected = false
var physics = false
var destroy_timer = 0.0
var despawn_timer = 0.0
var gravity : float
var velocity : Vector2

export var anim_damp = 80

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		CurrentLevelData.level_data.vars.coins_collected += 2
		CurrentLevelData.level_data.vars.red_coins_collected += 1
		body.heal(2)
		var player_id = 1
		if body.name == "Character":
			player_id = 0
		if PlayerSettings.other_player_id == -1 or PlayerSettings.my_player_index == player_id:
			sound.play()
		collected = true
		label.text = str(CurrentLevelData.level_data.vars.red_coins_collected)
		label.visible = true
		animated_sprite.animation = "collect"
		animated_sprite.frame = 0
		effects.visible = false
		destroy_timer = 2
		
func _ready():
	CurrentLevelData.level_data.vars.max_red_coins += 1
	var _connect = area.connect("body_entered", self, "collect")

func _process(delta):
	# warning-ignore: integer_division
	effects.rotation_degrees = (OS.get_ticks_msec()/16) % 360	

	if destroy_timer > 0:
		destroy_timer -= delta
		if destroy_timer <= 0:
			destroy_timer = 0
			queue_free()
	if despawn_timer > 0:
		despawn_timer -= delta
		if despawn_timer <= 1:
			visible = !visible
		if despawn_timer <= 0:
			if !sound.playing:
				despawn_timer = 0
				queue_free()
			else:
				despawn_timer = 0.3
	if !collected:
		animated_sprite.frame = (OS.get_ticks_msec() / anim_damp) % 4
	else:
		var label_color = label.modulate
		label_color.a -= 0.035
		label.modulate = label_color
		label.rect_position.y -= 0.75
