extends Control

onready var btn1=$Button
onready var btn2=$Button2
const SELECT_SFX=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Select - 1.mp3str")
const CURSOR_CLICK_1=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Cursor - 1.mp3str")


func _on_Button_pressed():
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_1
	$AudioStreamPlayer.play()
	self.visible=false
	DataMgr.set_setting("tutorial","is_first_tutorial",false)
	SceneMgr.change_scene("res://scene/tutorial/TutorialStartScene.tscn")

func _on_Button2_pressed():
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_1
	$AudioStreamPlayer.play()
	self.visible=false
	DataMgr.set_setting("tutorial","is_first_tutorial",false)
	SceneMgr.change_scene("res://scene/game_scene/start/StartScene.tscn")

func _on_TutorialOption_visibility_changed():
	#print("self.visible:",self.visible)
	get_tree().paused=self.visible
	#print("get_tree().paused:",get_tree().paused)


	


func _on_Button_mouse_entered():
	#播放音效
	$AudioStreamPlayer.stream=SELECT_SFX
	$AudioStreamPlayer.play()

func _on_Button2_mouse_entered():
	#播放音效
	$AudioStreamPlayer.stream=SELECT_SFX
	$AudioStreamPlayer.play()
