class_name ObjectManager
extends Node2D

var objects = []

func place_object(object: GameObject):
	objects.append(object)
	add_child(object)
