extends Control

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var fadeout: AnimationPlayer = $Fadeout

onready var label: Label = $Resizable/Label
onready var fill: TextureProgress = $Resizable/Fill

var max_shards: int

func _ready():
	# and this time, we have to wait for all the shine shard objects to load
	# (kind of a bad solution imo)
	for i in range(5):
		yield(get_tree(), "physics_frame")
#	var objects = get_node("/root").get_node("Player").get_shared_node().get_node("Objects")
#	yield(objects, "finished_loading")
	
	var variables: LevelVars = Singleton.CurrentLevelData.level_data.vars
	max_shards = variables.max_shine_shards
	fill.max_value = max_shards
	
	if max_shards > 0:
		visible = true
		variables.connect("shine_shard_collected", self, "collect_shard")
		
		var shard_amount = (
			variables.shine_shards_collected[
				Singleton.CurrentLevelData.area][0]
			)
		
		label.text = str(max_shards)
		fill.value = shard_amount


func collect_shard(new_shards: int):
	fill.value = new_shards
	if new_shards == fill.max_value:
		fadeout.play("fadeout")
	
	animation_player.stop()
	animation_player.play("collect")
	
	label.text = str(max_shards - new_shards)
