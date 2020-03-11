extends Node

export var background : NodePath
export var layer_1 : NodePath
export var layer_2 : NodePath
export var layer_3 : NodePath

onready var background_node := $background
onready var layer_1_node := $layer_1
onready var layer_2_node := $layer_2
onready var layer_3_node := $layer_3

func update(level_area: LevelArea):
	pass
