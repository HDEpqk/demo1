extends CanvasLayer


onready var panel=$PassedLevelPanel
var i:=0

func _ready():
	self.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PassedLevelPanel_visibility_changed():
	get_tree().paused=panel.visible


func _on_NextLevelButton_pressed():
	var next=i+1
	if next<Global.TUTORIAL_TOTAL_LEVEL:
		DataMgr.set_setting("tutorial","is_passed_level_%d"%next,true)
		SceneMgr.change_scene("res://scene/turorial/level_%d.tscn" % (next))
	else:
		SceneMgr.change_scene("res://scene/turorial/TutorialStartScene.tscn")


func _on_BackToTutorialStartButton_pressed():
	var next=i+1
	if next<Global.TUTORIAL_TOTAL_LEVEL:
		DataMgr.set_setting("tutorial","is_passed_level_%d"%next,true)
	SceneMgr.change_scene("res://scene/turorial/TutorialStartScene.tscn")

func init_passed_level(current_i:int):
	i=current_i
