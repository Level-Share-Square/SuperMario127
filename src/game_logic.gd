extends Node

const MARIO_SCENE = preload("res://scenes/actors/mario/Mario.tscn");

var reload = true;

func _physics_process(delta):
	if reload:
		reload = false;
		var mario = MARIO_SCENE.instance();
		mario.set_name("Mario");
	pass
