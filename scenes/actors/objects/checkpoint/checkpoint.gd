extends GameObject

export var normal_sparkles : Texture
export var used_sparkles : Texture

onready var use_area = $UseArea
onready var sound = $Use

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
	
	var _connect = use_area.connect("body_entered", self, "set_checkpoint")
	Singleton.CurrentLevelData.set_checkpoint_ids()
	id = level_object.get_ref().properties[7]
	if Singleton.CheckpointSaved.current_checkpoint_id == id:
		is_used = true
	
	Singleton.CurrentLevelData.level_data.vars.checkpoints.append([id, self])

func _physics_process(delta):
	var sprite = $Rotation/RotationRight
	var particles = $Rotation/RotationRight/Particles
	
	particles.texture = used_sparkles if is_used else normal_sparkles
	sprite.rotation_degrees += 8
	sprite.scale = sprite.scale.move_toward(Vector2(1, 1), delta * 4) if !is_used else sprite.scale.move_toward(Vector2(1.15, 1.15), delta * 8)

	var sprite2 = $Rotation/RotationLeft
	var particles2 = $Rotation/RotationLeft/Particles
	
	particles2.texture = used_sparkles if is_used else normal_sparkles
	sprite2.rotation_degrees -= 8
	sprite2.scale = sprite2.scale.move_toward(Vector2(1, 1), delta * 4) if !is_used else sprite2.scale.move_toward(Vector2(1.15, 1.15), delta * 8)

func set_checkpoint(body):
	if is_used or !enabled:
		return
	
	is_used = true
	
	Singleton.CheckpointSaved.current_checkpoint_id = id
	Singleton.CheckpointSaved.current_spawn_pos = global_position + spawn_offset
	Singleton.CheckpointSaved.current_area = Singleton.CurrentLevelData.area
	Singleton.CheckpointSaved.current_coins = Singleton.CurrentLevelData.level_data.vars.coins_collected
	Singleton.CheckpointSaved.nozzles_collected = Singleton.CurrentLevelData.level_data.vars.nozzles_collected.duplicate(true)
	Singleton.CheckpointSaved.current_red_coins = Singleton.CurrentLevelData.level_data.vars.red_coins_collected.duplicate(true)
	Singleton.CheckpointSaved.current_shine_shards = Singleton.CurrentLevelData.level_data.vars.shine_shards_collected.duplicate(true)
	Singleton.CheckpointSaved.current_purple_starbits = Singleton.CurrentLevelData.level_data.vars.purple_starbits_collected.duplicate(true)
	
	while Singleton.CurrentLevelData.level_data.vars.liquid_positions.size() <= Singleton.CurrentLevelData.area:
		Singleton.CurrentLevelData.level_data.vars.liquid_positions.append([])
	
	if save_water_level:
		Singleton.CurrentLevelData.level_data.vars.liquid_positions[Singleton.CurrentLevelData.area] = []
		for liquid in Singleton.CurrentLevelData.level_data.vars.liquids:
			Singleton.CurrentLevelData.level_data.vars.liquid_positions[Singleton.CurrentLevelData.area].append(liquid[1].save_pos)
	
	if save_switch_state:
		Singleton.CheckpointSaved.switch_state = Singleton.CurrentLevelData.level_data.vars.switch_state.duplicate(true)
	Singleton.CheckpointSaved.liquid_positions = Singleton.CurrentLevelData.level_data.vars.liquid_positions.duplicate(true)
	Singleton.CheckpointSaved.activated_shine_ids = Singleton.CurrentLevelData.level_data.vars.activated_shine_ids.duplicate(true)
	
	for checkpoint in Singleton.CurrentLevelData.level_data.vars.checkpoints:
		if checkpoint[1] != self:
			checkpoint[1].unset_checkpoint()
	
	if visible:
		sound.play()

func unset_checkpoint():
	is_used = false
