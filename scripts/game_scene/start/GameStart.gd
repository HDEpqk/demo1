extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.





func _on_start_animation_finished():
	SceneMgr.change_scene("res://scene/game_scene/start/StartScene.tscn")
