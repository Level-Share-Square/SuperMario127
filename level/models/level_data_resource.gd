class_name LevelDataResource
extends Resource


var _mutex: Mutex
# Indicates that this resource wasn't properly read from the level code, and that something or the entire object was replaced with a default value.
var faulty_resource: bool = false


# For threading. Lock the object before reading and writing it's data.
func lock() -> void:
	if not is_instance_valid(_mutex):
		_mutex = Mutex.new()
	
	_mutex.lock()


# For threading. Try locking the object before reading and writing it's data, if
# the thread should not be blocked.
func try_lock() -> bool:
	if not is_instance_valid(_mutex):
		_mutex = Mutex.new()
	
	return _mutex.try_lock() == OK


# For threading. Unlock the object after reading and writing it's data.
func unlock() -> void:
	if not is_instance_valid(_mutex):
		_mutex = Mutex.new()
	
	_mutex.unlock()


func mark_as_faulty(message: String) -> void:
	faulty_resource = true
	push_warning("A faulty level resource was made when decoding: " + message)
	
