extends Node2D

var load_paths = [
	["CurrentLevelData", "res://scenes/shared/level_data.tscn"],
	["ModeSwitcher", "res://scenes/actors/mode_switcher/mode_switcher.tscn"],
	["SceneTransitions", "res://scenes/actors/scene_transitions/CanvasLayer.tscn"],
	["Music", "res://scenes/actors/music/music.tscn"],
	["PlayerSettings", "res://scenes/player/player_settings.tscn"],
	["Networking", "res://scenes/shared/networking.tscn"],
	["FocusCheck", "res://scenes/player/focus_check.tscn"],
	["EditorSavedSettings", "res://scenes/editor/editor_saved_settings.tscn"],
	["PhotoMode", "res://scenes/actors/photo_mode/photo_mode.tscn"],
	["ActionManager", "res://scenes/editor/action_manager.tscn"],
	["MiscCache", "res://scenes/shared/misc_cache.tscn"],
	["Autosave", "res://scenes/editor/autosave.tscn"],
	["NotificationHandler", "res://scenes/shared/notification/notification_handler.tscn"],
	["SavedLevels", "res://scenes/shared/saved_levels.tscn"],
	["MenuVariables", "res://scenes/menu/menu_variables.tscn"],
	["TimeScore", "res://scenes/actors/time_score/time_score.tscn"],
	["MiscShared", "res://scenes/shared/miscshared.tscn"],
	["CheckpointSaved", "res://classes/CheckpointSaved.tscn"],
	["HideUI", "res://scenes/actors/hide_ui/hide_ui.tscn"],
	["CRTEffect", "res://scenes/crt_effect.tscn"],
	["LoadSettings", "res://scenes/shared/load_settings.tscn"]
]

var ModeSwitcher
var SceneTransitions
var Music
var CurrentLevelData
var PlayerSettings
var LoadSettings
var Networking
var FocusCheck
var EditorSavedSettings
var PhotoMode
var ActionManager
var MiscCache
var Autosave
var NotificationHandler
var SavedLevels
var MenuVariables
var TimeScore
var MiscShared
var CheckpointSaved
var HideUI
var CRTEffect

var loaded := false
