class_name EditorData
extends LevelDataResource


var loadouts: Array = []
var favorites: Array = []
var palettes: Array = []
var fav_items: Array = []


func _init(
		s_loadouts: Array = [], 
		s_favorites: Array = [], 
		s_palettes: Array = [], 
		s_fav_items: Array = []
	) -> void:
	loadouts = s_loadouts
	favorites = s_favorites
	palettes = s_palettes
	fav_items = s_fav_items
