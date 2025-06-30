extends Control

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var fadeout: AnimationPlayer = $Fadeout

onready var label: Label = $Resizable/Label
onready var fill: TextureProgress = $Resizable/Fill

var max_shards: int


func _ready():
	hide()
	var shared_node: LevelShared = get_tree().get_current_scene().get_shared_node()
	shared_node.get_node("Objects").connect("objects_ready", self, "delayed_ready")

func delayed_ready():
	var variables: LevelVars = Singleton.CurrentLevelData.level_data.vars
	max_shards = variables.max_shine_shards
	fill.max_value = max_shards
	
	if max_shards > 0:
		show()
		variables.connect("shine_shard_collected", self, "collect_shard")
		
		var shard_amount = (
			variables.shine_shards_collected[
				Singleton.CurrentLevelData.area][0]
			)
		
		label.text = str(max_shards-shard_amount)
		fill.value = shard_amount
		
		if label.text == "0":
			fadeout.play("fadeout")


func collect_shard(new_shards: int):
	fill.value = new_shards
	if new_shards == fill.max_value:
		fadeout.play("fadeout")
	
	animation_player.stop()
	animation_player.play("collect")
	
	label.text = str(max_shards - new_shards)
