extends GameObject

onready var animation_player = $AnimationPlayer
onready var animated_sprite = $AnimatedSprite
onready var area = $Area2D
onready var shape = $Area2D/CollisionShape2D
onready var visibility_enabler = $VisibilityEnabler2D
onready var tween = $Tween

var collected = false
var collectable = true
var despawn_timer = 0.0
var velocity : Vector2

var id : int
var timed : bool
var timer_on : bool

export var anim_damp = 80


func collect(body):
	if enabled and !collected and collectable and body.name.begins_with("Character") and !body.dead:
		Singleton.CurrentLevelData.level_data.vars.collect_purple_starbit(id)
		var player_id = 1
		if body.name == "Character":
			player_id = 0
		get_tree().current_scene.get_node("SharedSounds").PlaySound("PurpleSound")
		collected = true
		animation_player.play("collect")


func _ready():
	if mode == 1: return
	if enabled:
#		add_to_group("purple_starbits")
		id = Singleton.CurrentLevelData.level_data.vars.max_purple_starbits
		Singleton.CurrentLevelData.level_data.vars.max_purple_starbits += 1
	
	# band aid crash fix
	while Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected.size() <= Singleton.CurrentLevelData.area:
		Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected.append([0, []])
	
	if id in Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected[Singleton.CurrentLevelData.area][1] and !timed:
		queue_free()
	
	var _connect = area.connect("body_entered", self, "collect")

var prev_activate_shape = false
func _process(delta):
	if !timed:
		if despawn_timer > 0:
			despawn_timer -= delta
			if despawn_timer <= 1:
				visible = !visible
			if despawn_timer <= 0:
				despawn_timer = 0
				queue_free()
	
	if mode != 1:
		var root = get_tree().current_scene
		var activate_shape = false
		if !collected:
			var can_collect_coins = root.can_collect_coins
			for entity in can_collect_coins:
				if entity == null:
					can_collect_coins.erase(entity)
					continue
				
				var entity_global_position = entity.global_transform.get_origin()
				if (entity_global_position - position).length_squared() <= 200 + 472.25:
					activate_shape = true
		
		if activate_shape != prev_activate_shape:
			shape.disabled = !activate_shape
			prev_activate_shape = activate_shape
	
	if !collected:
		animated_sprite.frame = wrapi(OS.get_ticks_msec() / (1000/8), 0, 16)

#func turn_off():
#	var req_purples = Singleton.CurrentLevelData.level_data.vars.required_purple_starbits[Singleton.CurrentLevelData.area][0]
#	if Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected[Singleton.CurrentLevelData.area][0] < req_purples:
#		Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected[Singleton.CurrentLevelData.area] = [0, []]
#		timed = true
#		timer_on = false
#		enabled = false
#		collected = false
#		animated_sprite.animation = "purple"
#		tween.interpolate_property(animated_sprite, "self_modulate:A", 255, 0, 1)
#		tween.start()
#		yield(tween, "tween_all_completed")
#		visible = false
#		print("shut off")
#	elif (Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected[Singleton.CurrentLevelData.area][0] > req_purples) and (len(Singleton.CurrentLevelData.level_data.vars.required_purple_starbits[Singleton.CurrentLevelData.area]) > 1):
#		Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected[Singleton.CurrentLevelData.area][0] = req_purples
#		for _i in range(req_purples, Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected[Singleton.CurrentLevelData.area][0]):
#			var popped_id = Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected[Singleton.CurrentLevelData.area][1].pop_back()
#			if id == popped_id:
#				timed = true
#				timer_on = false
#				enabled = false
#				collected = false
#
#
#func turn_on():
#	tween.interpolate_property(animated_sprite, "self_modulate:A", 0, 255, 1)
#	tween.start()
#	yield(tween, "tween_all_completed")
#	visible = true
#	timer_on = true
#	enabled = true
