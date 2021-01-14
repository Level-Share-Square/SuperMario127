extends GameObject

export var normal_sparkles : Texture
export var used_sparkles : Texture

onready var use_area = $UseArea
onready var sound = $Use

var is_used := false
var save_water_level := true
var spawn_y_offset := 0.0
var id = 0

func _set_properties():
	savable_properties = ["save_water_level", "spawn_y_offset"]
	editable_properties = ["save_water_level", "spawn_y_offset"]
	
func _set_property_values():
	set_property("save_water_level", save_water_level, true)
	set_property("spawn_y_offset", spawn_y_offset, true)

func _ready():
	id = CurrentLevelData.level_data.vars.checkpoints.size()
	CurrentLevelData.level_data.vars.checkpoints.append([id, self])
	
	if CheckpointSaved.current_checkpoint_id == id:
		is_used = true

	var _connect = use_area.connect("body_entered", self, "set_checkpoint")

func _physics_process(delta):
	var sprite = $Rotation/RotationRight
	var particles = $Rotation/RotationRight/Particles
	
	particles.texture = used_sparkles if is_used else normal_sparkles
	sprite.rotation_degrees += 4
	sprite.scale = sprite.scale.move_toward(Vector2(1, 1), delta * 4) if !is_used else sprite.scale.move_toward(Vector2(1.15, 1.15), delta * 8)

	var sprite2 = $Rotation/RotationLeft
	var particles2 = $Rotation/RotationLeft/Particles
	
	particles2.texture = used_sparkles if is_used else normal_sparkles
	sprite2.rotation_degrees -= 4
	sprite2.scale = sprite2.scale.move_toward(Vector2(1, 1), delta * 4) if !is_used else sprite2.scale.move_toward(Vector2(1.15, 1.15), delta * 8)

func set_checkpoint(body):
	if is_used or !enabled:
		return
	
	is_used = true
	CheckpointSaved.current_checkpoint_id = id
	CheckpointSaved.current_spawn_pos = global_position + Vector2(0, spawn_y_offset)
	CheckpointSaved.current_area = CurrentLevelData.area
	CheckpointSaved.current_coins = CurrentLevelData.level_data.vars.coins_collected
	CheckpointSaved.nozzles_collected = CurrentLevelData.level_data.vars.nozzles_collected.duplicate(true)
	CheckpointSaved.current_red_coins = CurrentLevelData.level_data.vars.red_coins_collected.duplicate(true)
	CheckpointSaved.current_shine_shards = CurrentLevelData.level_data.vars.shine_shards_collected.duplicate(true)
	
	if save_water_level:
		CurrentLevelData.level_data.vars.liquid_positions[CurrentLevelData.area] = []
		for liquid in CurrentLevelData.level_data.vars.liquids:
			CurrentLevelData.level_data.vars.liquid_positions[CurrentLevelData.area].append(liquid[1].save_pos)
	CheckpointSaved.liquid_positions = CurrentLevelData.level_data.vars.liquid_positions
	
	for checkpoint in CurrentLevelData.level_data.vars.checkpoints:
		if checkpoint[1] != self:
			checkpoint[1].unset_checkpoint()
	
	if visible:
		sound.play()

func unset_checkpoint():
	is_used = false
