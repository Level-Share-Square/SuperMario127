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
	savable_properties = ["save_water_level", "spawn_y_offset", "id"]
	editable_properties = ["save_water_level", "spawn_y_offset"]
	
func _set_property_values():
	set_property("save_water_level", save_water_level, true)
	set_property("spawn_y_offset", spawn_y_offset, true)

func _ready():
	if is_preview: return
	
	var _connect = use_area.connect("body_entered", self, "set_checkpoint")
	Singleton.CurrentLevelData.set_checkpoint_ids()
	id = level_object.get_ref().properties[6]
	if Singleton.CheckpointSaved.current_checkpoint_id == id:
		is_used = true

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
	Singleton.CheckpointSaved.current_spawn_pos = global_position + Vector2(0, spawn_y_offset)
	Singleton.CheckpointSaved.current_area = Singleton.CurrentLevelData.area
	Singleton.CheckpointSaved.current_coins = Singleton.CurrentLevelData.level_data.vars.coins_collected
	Singleton.CheckpointSaved.nozzles_collected = Singleton.CurrentLevelData.level_data.vars.nozzles_collected.duplicate(true)
	Singleton.CheckpointSaved.current_red_coins = Singleton.CurrentLevelData.level_data.vars.red_coins_collected.duplicate(true)
	Singleton.CheckpointSaved.current_shine_shards = Singleton.CurrentLevelData.level_data.vars.shine_shards_collected.duplicate(true)
	
	if save_water_level:
		Singleton.CurrentLevelData.level_data.vars.liquid_positions[Singleton.CurrentLevelData.area] = []
		for liquid in Singleton.CurrentLevelData.level_data.vars.liquids:
			Singleton.CurrentLevelData.level_data.vars.liquid_positions[Singleton.CurrentLevelData.area].append(liquid[1].save_pos)
	Singleton.CheckpointSaved.liquid_positions = Singleton.CurrentLevelData.level_data.vars.liquid_positions
	
	for checkpoint in Singleton.CurrentLevelData.level_data.vars.checkpoints:
		if checkpoint[1] != self:
			checkpoint[1].unset_checkpoint()
	
	if visible:
		sound.play()

func unset_checkpoint():
	is_used = false
