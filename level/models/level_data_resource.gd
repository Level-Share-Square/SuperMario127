class_name LevelDataResource
extends Resource


var _mutex: Mutex


func _init() -> void:
	_mutex = Mutex.new()


# For threading. Lock the object before reading and writing it's data.
func lock() -> void:
	_mutex.lock()


# For threading. Unlock the object after reading and writing it's data.
func unlock() -> void:
	_mutex.unlock()
