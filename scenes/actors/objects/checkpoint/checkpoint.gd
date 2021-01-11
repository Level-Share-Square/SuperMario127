extends GameObject

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
	var sprite = $Rotation/Rotation2
	sprite.modulate = lerp(sprite.modulate, Color(1, 0, 0), delta * 32) if is_used else lerp(sprite.modulate, Color(1, 1, 1), delta * 4)
	sprite.rotation_degrees += 4
	sprite.scale = sprite.scale.move_toward(Vector2(1, 1), delta * 4) if !is_used else sprite.scale.move_toward(Vector2(1.15, 1.15), delta * 8)

func set_checkpoint(body):
	if is_used:
		return
	
	is_used = true
	CheckpointSaved.current_checkpoint_id = id
	CheckpointSaved.current_spawn_pos = global_position + Vector2(0, spawn_y_offset)
	CheckpointSaved.current_coins = CurrentLevelData.level_data.vars.coins_collected
	CheckpointSaved.nozzles_collected = CurrentLevelData.level_data.vars.nozzles_collected.duplicate()
	
	var red_coins_array = CurrentLevelData.level_data.vars.red_coins_collected.duplicate()
	CheckpointSaved.current_red_coins = [red_coins_array[0], red_coins_array[1].duplicate()]
	
	var shine_shards_array = CurrentLevelData.level_data.vars.shine_shards_collected.duplicate()
	
	CheckpointSaved.current_shine_shards = [shine_shards_array[0], shine_shards_array[1].duplicate()]
	
	if save_water_level:
		CheckpointSaved.liquid_positions = []
		for liquid in CurrentLevelData.level_data.vars.liquids:
			CheckpointSaved.liquid_positions.append(liquid[1].save_pos)
	
	for checkpoint in CurrentLevelData.level_data.vars.checkpoints:
		if checkpoint[1] != self:
			checkpoint[1].unset_checkpoint()
	
	if visible:
		sound.play()

func unset_checkpoint():
	is_used = false
