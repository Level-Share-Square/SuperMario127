extends Node2D

var load_paths = [
	["PlayerSettings", "res://scenes/player/player_settings.tscn"],
	["EditorSavedSettings", "res://scenes/editor/editor_saved_settings.tscn"],
	["TimeScore", "res://scenes/actors/time_score/time_score.tscn"],
	["SettingsLoader", "res://singletons/settings_loader.tscn"],
	["CurrentLevelData", "res://scenes/shared/level_data.tscn"],
	["ModeSwitcher", "res://scenes/actors/mode_switcher/mode_switcher.tscn"],
	["SceneTransitions", "res://scenes/actors/scene_transitions/CanvasLayer.tscn"],
	["SceneSwitcher", "res://singletons/scene_switcher.tscn"],
	["Music", "res://scenes/actors/music/music.tscn"],
	["PhotoMode", "res://scenes/actors/photo_mode/photo_mode.tscn"],
	["ActionManager", "res://scenes/editor/action_manager.tscn"],
	["MiscCache", "res://scenes/shared/misc_cache.tscn"],
	["Autosave", "res://scenes/editor/autosave.tscn"],
	["NotificationHandler", "res://scenes/shared/notification/notification_handler.tscn"],
	["MiscShared", "res://scenes/shared/miscshared.tscn"],
	["CheckpointSaved", "res://classes/CheckpointSaved.tscn"],
]

var PlayerSettings
var EditorSavedSettings
var TimeScore
var SettingsLoader
var CurrentLevelData
var ModeSwitcher
var SceneTransitions
var SceneSwitcher
var Music
var PhotoMode
var ActionManager
var MiscCache
var Autosave
var NotificationHandler
var MiscShared
var CheckpointSaved

var loaded := false
