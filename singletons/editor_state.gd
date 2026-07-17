extends Node
## Transient runtime state owned by the editor: hotkey suppression and the autosave countdown.

const AUTOSAVE_INTERVAL: int = 108000

var disable_hotkeys: bool = false
var time: int = 0


func reset_time() -> void:
	time = AUTOSAVE_INTERVAL
