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
var velocity : Vector2

var id : int

export var anim_damp = 80

func collect(body):
	if is_enabled_and_on_ground() and !collected and body.name.begins_with("Character") and !body.dead:
		CurrentLevelData.vars.collect_shine_shard(id)
		var player_id = 1
		if body.name == "Character":
			player_id = 0
		if Singleton.PlayerSettings.other_player_id == -1 or Singleton.PlayerSettings.my_player_index == player_id:
			sound.play()
		collected = true
		
		label.text = str(CurrentLevelData.vars.shine_shards_collected[CurrentLevelData.area_id][0])
		
		#all of the collecting animation takes place in the animation player now, any old commented
		#out code is part of the old animation and is simply left here to revert if necessary
		animation_player.play("collect")
		
#		label.visible = true
		#animated_sprite.animation = "collect"
		#animated_sprite.frame = 0
#		animated_sprite.visible = false
#		destroy_timer = 2
		
func _ready():
	if mode == 1:
		#if in the editor, use the base position and modulate values of the shine shard, then exit _ready()
		animation_player.play("RESET")
		return
	
	if is_enabled_and_on_ground():
		id = CurrentLevelData.vars.max_shine_shards
		CurrentLevelData.vars.max_shine_shards += 1
	
	# band aid crash fix
	while CurrentLevelData.vars.shine_shards_collected.size() <= CurrentLevelData.area_id:
		CurrentLevelData.vars.shine_shards_collected.append([0, []])
	
	if id in CurrentLevelData.vars.shine_shards_collected[CurrentLevelData.area_id][1]:
		queue_free()
	
	var _connect = area.connect("body_entered", self, "collect")
	animation_player.play("default")

func _process(delta):
#	if destroy_timer > 0:
#		destroy_timer -= delta
#		if destroy_timer <= 0:
#			destroy_timer = 0
#			queue_free()
#	if despawn_timer > 0:
#		despawn_timer -= delta
#		if despawn_timer <= 1:
#			visible = !visible
#		if despawn_timer <= 0:
#			if !sound.playing:
#				despawn_timer = 0
#				queue_free()
#			else:
#				despawn_timer = 0.3

	if collected:
		if sparkles.emitting:
			sparkles.emitting = false
