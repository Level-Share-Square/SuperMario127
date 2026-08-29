extends GameObject

export var normal_sparkles : Texture
export var used_sparkles : Texture

onready var use_area = $UseArea
onready var sound = $Use
onready var display = $Display

var is_used := false

var save_water_level := true
var save_switch_state := true
var spawn_offset := Vector2(0,0)
var id = 0


#func _set_properties():
#	savable_properties = ["save_water_level", "spawn_offset", "save_switch_state", "id"]
#	editable_properties = ["save_water_level", "save_switch_state", "spawn_offset"]


func _register_properties():
	register_property(4, "save_water_level", save_water_level, true)
	register_property(5, "spawn_offset", spawn_offset, true)
	register_property(6, "save_switch_state", save_switch_state, true)


func _object_ready():
	display.visible = false
	if is_enabled_and_on_ground():
		var _connect = use_area.connect("body_entered", self, "set_checkpoint")
	
	id = hash([position, CurrentLevelData.area_id])
	if CurrentLevelData.checkpoint_data.current_checkpoint_id == id:
		is_used = true
	
	CurrentLevelData.vars.checkpoints.append([id, self])
	


func _editor_ready():
	display.visible = true

func _object_process(delta: float):
	update_ring_particles(delta)


func _editor_process(delta: float):
	display.global_scale = Vector2.ONE
	update_ring_particles(delta)


func update_ring_particles(delta: float):
	if not $"%VisibilityEnabler2D".is_on_screen():
		return
	
	var sprite = $Rotation/RotationRight
	var particles = $Rotation/RotationRight/Particles
	
	particles.texture = used_sparkles if is_used else normal_sparkles
#	sprite.reset_physics_interpolation()
	sprite.rotate(deg2rad(8) * delta * 60)
	
	sprite.scale = sprite.scale.move_toward(Vector2(1, 1), delta * 4) if !is_used else sprite.scale.move_toward(Vector2(1.15, 1.15), delta * 8)

	var sprite2 = $Rotation/RotationLeft
	var particles2 = $Rotation/RotationLeft/Particles
	
	particles2.texture = used_sparkles if is_used else normal_sparkles
#	sprite2.reset_physics_interpolation()
	sprite2.rotate(deg2rad(-8) * delta * 60)
	
	sprite2.scale = sprite2.scale.move_toward(Vector2(1, 1), delta * 4) if !is_used else sprite2.scale.move_toward(Vector2(1.15, 1.15), delta * 8)


func set_checkpoint(body):
	if is_used or !is_enabled_and_on_ground():
		return
	
	is_used = true
	
	CurrentLevelData.checkpoint_data.current_checkpoint_id = id
	CurrentLevelData.checkpoint_data.current_spawn_pos = global_position + spawn_offset
	CurrentLevelData.checkpoint_data.current_area = CurrentLevelData.area_id
	CurrentLevelData.checkpoint_data.current_coins = CurrentLevelData.vars.coins_collected
	CurrentLevelData.checkpoint_data.nozzles_collected = CurrentLevelData.vars.nozzles_collected.duplicate(true)
	CurrentLevelData.checkpoint_data.current_red_coins = CurrentLevelData.vars.red_coins_collected.duplicate(true)
	CurrentLevelData.checkpoint_data.current_shine_shards = CurrentLevelData.vars.shine_shards_collected.duplicate(true)
	CurrentLevelData.checkpoint_data.current_purple_starbits = CurrentLevelData.vars.purple_starbits_collected.duplicate(true)
	CurrentLevelData.checkpoint_data.current_local_keys = CurrentLevelData.vars.local_keys_collected.duplicate(true)
	CurrentLevelData.checkpoint_data.current_layer = level_layer_ref.get_ref().layer_data.layer_metadata.layer_uuid
	CurrentLevelData.checkpoint_data.current_layer_states = CurrentLevelData.vars.layer_states.duplicate(true)
	while CurrentLevelData.vars.liquid_positions.size() <= CurrentLevelData.area_id:
		CurrentLevelData.vars.liquid_positions.append([])
	
	if save_water_level:
		CurrentLevelData.vars.liquid_positions[CurrentLevelData.area_id] = []
		for liquid in CurrentLevelData.vars.liquids:
			CurrentLevelData.vars.liquid_positions[CurrentLevelData.area_id].append(liquid[1].save_pos)
	
	if save_switch_state:
		CurrentLevelData.checkpoint_data.switch_state = CurrentLevelData.vars.switch_state.duplicate(true)
	CurrentLevelData.checkpoint_data.liquid_positions = CurrentLevelData.vars.liquid_positions.duplicate(true)
	CurrentLevelData.checkpoint_data.activated_shine_ids = CurrentLevelData.vars.activated_shine_ids.duplicate(true)
	
	CurrentLevelData.level_transition_data = {}
	
	for checkpoint in CurrentLevelData.vars.checkpoints:
		if checkpoint[1] != self:
			checkpoint[1].unset_checkpoint()
	
	if visible:
		sound.play()

func unset_checkpoint():
	is_used = false
