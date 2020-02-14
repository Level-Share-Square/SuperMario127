extends Resource

class_name LevelArea

var objects = [];
var backgroundTiles: PoolStringArray;
var foregroundTiles: PoolStringArray;
var settings: LevelAreaSettings;

func loadIn(node: Node):
	var character = node.get_node("../Character")
	var levelObjects = node.get_node("../LevelObjects")
	character.position = settings.spawn;
