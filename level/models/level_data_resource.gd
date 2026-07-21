class_name LevelDataResource
extends Resource


var _mutex: Mutex
# Indicates that this resource wasn't properly read from the level code, and that something or the entire object was replaced with a default value.
var faulty_resource: bool = false

func _init() -> void:
	_mutex = Mutex.new()


# For threading. Lock the object before reading and writing it's data.
func lock() -> void:
	_mutex.lock()


# For threading. Unlock the object after reading and writing it's data.
func unlock() -> void:
	_mutex.unlock()
	
func mark_as_faulty(message: String) -> void:
	faulty_resource = true
	push_warning("A faulty level resource was made when decoding: " + message)
	
