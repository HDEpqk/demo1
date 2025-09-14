extends Control


onready var btn1=$BK/Button
onready var btn2=$BK/Button2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.





func _on_Button_pressed():
	self.visible=false
	DataMgr.set_setting("tutorial","is_first_tutorial",false)
	SceneMgr.change_scene("res://scene/tutorial/TutorialStartScene.tscn")

func _on_Button2_pressed():
	self.visible=false
	DataMgr.set_setting("tutorial","is_first_tutorial",false)
	SceneMgr.change_scene("res://scene/game_scene/start/StartScene.tscn")

func _on_TutorialOption_visibility_changed():
	#print("self.visible:",self.visible)
	get_tree().paused=self.visible
	#print("get_tree().paused:",get_tree().paused)


	
