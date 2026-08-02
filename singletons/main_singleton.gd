extends Node
## Service locator: lazily instances and hands out the game's shared global nodes.

## bunch of lazy loading setups here, this makes it basically so the game only loads
## these nodes when the game needs them instead of everything being loaded at the start
func lazy_get(node_name: String, scene_path: String, node: Node) -> Node:
	# already loaded? just return that
	if is_instance_valid(node):
		return node

	# otherwise load the scene and add it as a child node first
	var loaded_scene: Node = load(scene_path).instance()
	self[node_name] = loaded_scene
	add_child(loaded_scene)
	return loaded_scene


## all the singleton nodes, with getters setup for lazy loading
## i dislike this setup but my hands are kind of tied...
## it would have been nice if we either had better automation of getters
## or the original devs of this game DIDNT USE SINGLETONS ON EVERYTHING >:C
var PlayerSettings setget ,_get_player_settings
func _get_player_settings() -> Node:
	return lazy_get("PlayerSettings", "res://scenes/player/player_settings.tscn", PlayerSettings)

var EditorSavedSettings setget ,_get_editor_saved_settings
func _get_editor_saved_settings() -> Node:
	return lazy_get("EditorSavedSettings", "res://scenes/oldeditor/editor_saved_settings.tscn", EditorSavedSettings)

var ModeSwitcher setget ,_get_mode_switcher
func _get_mode_switcher() -> Node:
	return lazy_get("ModeSwitcher", "res://scenes/actors/mode_switcher_old/mode_switcher.tscn", ModeSwitcher)

var SceneSwitcher setget ,_get_scene_switcher
func _get_scene_switcher() -> Node:
	return lazy_get("SceneSwitcher", "res://singletons/scene_switcher.tscn", SceneSwitcher)

var Music setget ,_get_music
func _get_music() -> Node:
	return lazy_get("Music", "res://scenes/actors/music/music.tscn", Music)

var PhotoMode setget ,_get_photo_mode
func _get_photo_mode() -> Node:
	return lazy_get("PhotoMode", "res://scenes/actors/photo_mode/photo_mode.tscn", PhotoMode)

var ActionManager setget ,_get_action_manager
func _get_action_manager() -> Node:
	return lazy_get("ActionManager", "res://scenes/oldeditor/action_manager.tscn", ActionManager)

var MiscCache setget ,_get_misc_cache
func _get_misc_cache() -> Node:
	return lazy_get("MiscCache", "res://scenes/shared/misc_cache.tscn", MiscCache)

var NotificationHandler setget ,_get_notification_handler
func _get_notification_handler() -> Node:
	return lazy_get("NotificationHandler", "res://scenes/shared/notification/notification_handler.tscn", NotificationHandler)

var MiscShared setget ,_get_misc_shared
func _get_misc_shared() -> Node:
	return lazy_get("MiscShared", "res://scenes/shared/miscshared.tscn", MiscShared)
