class_name ObjectManager
extends Node2D

var objects = []


func load_in(s_layer_data: LayerData):
	pass


func place_object(object: GameObject):
	objects.append(object)
	add_child(object)
