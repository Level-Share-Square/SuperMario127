class_name LevelSong
extends Resource

enum Type {GROUND, UNDERGROUND, SECRET}

export var stream : AudioStream
export var underwater_stream : AudioStream
export var blended_stream : AudioStream

export var stream_link: String
export var underwater_stream_link : String
export var blended_stream_link : String

export var volume_db := 0
export var pitch_scale := 1
export var title : String
export var note : String
export(Type) var type
