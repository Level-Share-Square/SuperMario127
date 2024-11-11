extends Node

## bunch of lazy loading setups here, this makes it basically so the game only loads
## these nodes when the game needs them instead of everything being loaded at the start
func lazy_get(node_name: String, scene_path: String, node):
	# already loaded? just return that
	if is_instance_valid(node):
		return node
	
	# otherwise load the scene and add it as a child node first
	var loaded_scene = load(scene_path).instance()
	self[node_name] = loaded_scene
	add_child(loaded_scene)
	return loaded_scene


## all the singleton nodes, with getters setup for lazy loading
## i dislike this setup but my hands are kind of tied...
## it would have been nice if we either had better automation of getters
## or the original devs of this game DIDNT USE SINGLETONS ON EVERYTHING >:C
var PlayerSettings setget ,_get_player_settings
func _get_player_settings():
	return lazy_get("PlayerSettings", "res://scenes/player/player_settings.tscn", PlayerSettings)

var EditorSavedSettings setget ,_get_editor_saved_settings
func _get_editor_saved_settings():
	return lazy_get("EditorSavedSettings", "res://scenes/editor/editor_saved_settings.tscn", EditorSavedSettings)

var CurrentLevelData setget ,_get_current_level_data
func _get_current_level_data():
	return lazy_get("CurrentLevelData", "res://scenes/shared/level_data.tscn", CurrentLevelData)

var ModeSwitcher setget ,_get_mode_switcher
func _get_mode_switcher():
	return lazy_get("ModeSwitcher", "res://scenes/actors/mode_switcher/mode_switcher.tscn", ModeSwitcher)

var SceneTransitions setget ,_get_scene_transitions
func _get_scene_transitions():
	return lazy_get("SceneTransitions", "res://scenes/actors/scene_transitions/CanvasLayer.tscn", SceneTransitions)

var SceneSwitcher setget ,_get_scene_switcher
func _get_scene_switcher():
	return lazy_get("SceneSwitcher", "res://singletons/scene_switcher.tscn", SceneSwitcher)

var Music setget ,_get_music
func _get_music():
	return lazy_get("Music", "res://scenes/actors/music/music.tscn", Music)

var PhotoMode setget ,_get_photo_mode
func _get_photo_mode():
	return lazy_get("PhotoMode", "res://scenes/actors/photo_mode/photo_mode.tscn", PhotoMode)

var ActionManager setget ,_get_action_manager
func _get_action_manager():
	return lazy_get("ActionManager", "res://scenes/editor/action_manager.tscn", ActionManager)

var MiscCache setget ,_get_misc_cache
func _get_misc_cache():
	return lazy_get("MiscCache", "res://scenes/shared/misc_cache.tscn", MiscCache)

var Autosave setget ,_get_autosave
func _get_autosave():
	return lazy_get("Autosave", "res://scenes/editor/autosave.tscn", Autosave)

var NotificationHandler setget ,_get_notifaction_handler
func _get_notifaction_handler():
	return lazy_get("NotificationHandler", "res://scenes/shared/notification/notification_handler.tscn", NotificationHandler)

var MiscShared setget ,_get_misc_shared
func _get_misc_shared():
	return lazy_get("MiscShared", "res://scenes/shared/miscshared.tscn", MiscShared)

var CheckpointSaved setget ,_get_checkpoint_saved
func _get_checkpoint_saved():
	return lazy_get("CheckpointSaved", "res://classes/CheckpointSaved.tscn", CheckpointSaved)
