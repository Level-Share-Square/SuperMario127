extends Control


const NEW_GAME: String = "New Game"

onready var file_manager = $"%FileManager"
onready var collectibles = $Button/Info/VBoxContainer/Collectibles
onready var shines_label = $Button/Info/VBoxContainer/Collectibles/Shines/ShinesLabel
onready var star_coins_label = $Button/Info/VBoxContainer/Collectibles/StarCoins/StarCoinsLabel
onready var completion = $Button/Info/VBoxContainer/Completion

export var file_id: int = 0
var campaign_path: String
var file_exists: bool
# saved because the game should send you to the intro level if you don't have any shines
var collected_shines: int = 0


func play_level():
	var save_folder: String = level_list_util.get_save_folder(campaign_path, file_id)
	if not level_list_util.file_exists(save_folder + "meta.127save"):
		create_file()
	file_manager.play_level(file_id, collected_shines)


func load_file_info(_campaign_path: String):
	campaign_path = _campaign_path
	
	var save_folder: String = level_list_util.get_save_folder(campaign_path, file_id)
	if not level_list_util.file_exists(save_folder + "meta.127save"):
		file_exists = false
		collectibles.visible = false
		completion.text = NEW_GAME
	else:
		file_exists = true
		
		var meta_dict: Dictionary = save_meta_util.load_meta_file(save_folder)
		var total_dict: Dictionary = save_meta_util.get_collectible_totals(meta_dict)
		collectibles.visible = true
		
		collected_shines = total_dict.get("collected_shines", 0)
		var total_shines: int = total_dict.get("total_shines", 0)
		shines_label.text = "%s/%s" % [collected_shines, total_shines]
		
		var collected_star_coins: int = total_dict.get("collected_star_coins", 0)
		var total_star_coins: int = total_dict.get("total_star_coins", 0)
		star_coins_label.text = "%s/%s" % [collected_star_coins, total_star_coins]
		
		var shines_percentage: float = float(collected_shines) / max(total_shines, 1)
		var star_coins_percentage: float = float(collected_star_coins) / max(total_star_coins, 1)
		var total_percentage: float = shines_percentage*50 + star_coins_percentage*50
		total_percentage = floor(total_percentage)
		completion.text = str(total_percentage) + "%"


func create_file():
	var meta_dict: Dictionary = save_meta_util.update_meta({}, campaign_path, file_id)
	var save_folder: String = level_list_util.get_save_folder(campaign_path, file_id)
	save_meta_util.save_meta_file(save_folder, meta_dict)
	file_exists = true
