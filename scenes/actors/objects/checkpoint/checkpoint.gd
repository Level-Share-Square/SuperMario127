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

func _set_properties():
	savable_properties = ["save_water_level", "spawn_offset", "save_switch_state", "id"]
	editable_properties = ["save_water_level", "save_switch_state", "spawn_offset"]
	
func _set_property_values():
	set_property("save_water_level", save_water_level, true)
	set_property("spawn_offset", spawn_offset, true)
	set_property("save_switch_state", save_switch_state, true)

func _ready():
	if is_preview: return
	
	if mode != 1:
		display.visible = false
		var _connect = use_area.connect("body_entered", self, "set_checkpoint")
	else:
		display.visible = true
	
#	CurrentLevelData.set_checkpoint_ids()
#	id = level_object.get_ref().properties[9]
	if Singleton.CheckpointSaved.current_checkpoint_id == id:
		is_used = true
	
	CurrentLevelData.vars.checkpoints.append([id, self])

func _physics_process(delta):
	var sprite = $Rotation/RotationRight
	var particles = $Rotation/RotationRight/Particles
	
	particles.texture = used_sparkles if is_used else normal_sparkles
#	sprite.reset_physics_interpolation()
	sprite.rotate(deg2rad(8))
	
	sprite.scale = sprite.scale.move_toward(Vector2(1, 1), delta * 4) if !is_used else sprite.scale.move_toward(Vector2(1.15, 1.15), delta * 8)

	var sprite2 = $Rotation/RotationLeft
	var particles2 = $Rotation/RotationLeft/Particles
	
	particles2.texture = used_sparkles if is_used else normal_sparkles
#	sprite2.reset_physics_interpolation()
	sprite2.rotate(deg2rad(-8))
	
	sprite2.scale = sprite2.scale.move_toward(Vector2(1, 1), delta * 4) if !is_used else sprite2.scale.move_toward(Vector2(1.15, 1.15), delta * 8)

func set_checkpoint(body):
	if is_used or !enabled:
		return
	
	is_used = true
	
	Singleton.CheckpointSaved.current_checkpoint_id = id
	Singleton.CheckpointSaved.current_spawn_pos = global_position + spawn_offset
	Singleton.CheckpointSaved.current_area = CurrentLevelData.area_id
	Singleton.CheckpointSaved.current_coins = CurrentLevelData.vars.coins_collected
	Singleton.CheckpointSaved.nozzles_collected = CurrentLevelData.vars.nozzles_collected.duplicate(true)
	Singleton.CheckpointSaved.current_red_coins = CurrentLevelData.vars.red_coins_collected.duplicate(true)
	Singleton.CheckpointSaved.current_shine_shards = CurrentLevelData.vars.shine_shards_collected.duplicate(true)
	Singleton.CheckpointSaved.current_purple_starbits = CurrentLevelData.vars.purple_starbits_collected.duplicate(true)
	Singleton.CheckpointSaved.current_local_keys = CurrentLevelData.vars.local_keys_collected.duplicate(true)
	
	while CurrentLevelData.vars.liquid_positions.size() <= CurrentLevelData.area_id:
		CurrentLevelData.vars.liquid_positions.append([])
	
	if save_water_level:
		CurrentLevelData.vars.liquid_positions[CurrentLevelData.area_id] = []
		for liquid in CurrentLevelData.vars.liquids:
			CurrentLevelData.vars.liquid_positions[CurrentLevelData.area_id].append(liquid[1].save_pos)
	
	if save_switch_state:
		Singleton.CheckpointSaved.switch_state = CurrentLevelData.vars.switch_state.duplicate(true)
	Singleton.CheckpointSaved.liquid_positions = CurrentLevelData.vars.liquid_positions.duplicate(true)
	Singleton.CheckpointSaved.activated_shine_ids = CurrentLevelData.vars.activated_shine_ids.duplicate(true)
	
	CurrentLevelData.level_transition_data = {}
	
	for checkpoint in CurrentLevelData.vars.checkpoints:
		if checkpoint[1] != self:
			checkpoint[1].unset_checkpoint()
	
	if visible:
		sound.play()

func unset_checkpoint():
	is_used = false
