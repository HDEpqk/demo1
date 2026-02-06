extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	var scene_name=get_tree().current_scene.name
	SceneMgr.game_scene_name=scene_name
		


