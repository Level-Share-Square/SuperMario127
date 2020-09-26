extends GameObject

onready var animated_sprite = $AnimatedSprite
onready var sound = $AudioStreamPlayer
onready var area = $Area2D
onready var visibility_enabler = $VisibilityEnabler2D
onready var label = $Label
onready var sparkles = $Sparkles
onready var animation_player = $AnimationPlayer

var collected = false
var physics = false
var destroy_timer = 0.0
var despawn_timer = 0.0
var gravity : float
var velocity : Vector2

export var anim_damp = 80

func collect(body):
	if enabled and !collected and body.name.begins_with("Character") and !body.dead:
		CurrentLevelData.level_data.vars.shine_shards_collected += 1
		var player_id = 1
		if body.name == "Character":
			player_id = 0
		if PlayerSettings.other_player_id == -1 or PlayerSettings.my_player_index == player_id:
			sound.play()
		collected = true
		label.text = str(CurrentLevelData.level_data.vars.shine_shards_collected)
		label.visible = true
		#animated_sprite.animation = "collect"
		#animated_sprite.frame = 0
		animated_sprite.visible = false
		sparkles.emitting = false
		destroy_timer = 2
		
func _ready():
	CurrentLevelData.level_data.vars.max_shine_shards += 1
	var _connect = area.connect("body_entered", self, "collect")
	animation_player.play("default")

func _process(delta):
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
		animated_sprite.frame = wrapi(OS.get_ticks_msec() / (1000/8), 0, 16)
	else:
		var label_color = label.modulate
		label_color.a -= 0.035
		label.modulate = label_color
		label.rect_position.y -= 0.75
