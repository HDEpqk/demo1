extends CanvasLayer

const SELECT_SFX=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Select - 1.mp3str")
const CURSOR_CLICK_1=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Cursor - 1.mp3str")
onready var panel=$PassedLevelPanel
var i:=1

func _ready():
	self.hide()
	
	#测试用于解锁全部关卡
#	for i in range(7):
#		DataMgr.set_setting("tutorial","is_passed_level_%d"%(i+1),true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PassedLevelPanel_visibility_changed():
#	if panel.visible==true:
#		$"../TeachingDisplay".pause_mode=Node.PAUSE_MODE_INHERIT
	get_tree().paused=panel.visible


func _on_NextLevelButton_pressed():
	var next=i+1
	if next<=Global.TUTORIAL_TOTAL_LEVEL:
		if !DataMgr.get_setting("tutorial","is_passed_level_%d"%next):
			DataMgr.set_setting("tutorial","is_passed_level_%d"%next,true)
		SceneMgr.change_scene("res://scene/tutorial/levels/level_%d.tscn" % next)
	else:
		SceneMgr.change_scene("res://scene/tutorial/TutorialStartScene.tscn")


func _on_BackToTutorialStartButton_pressed():
	var next=i+1
	if next<=Global.TUTORIAL_TOTAL_LEVEL:
		if !DataMgr.get_setting("tutorial","is_passed_level_%d"%next):
			DataMgr.set_setting("tutorial","is_passed_level_%d"%next,true)
	SceneMgr.change_scene("res://scene/tutorial/TutorialStartScene.tscn")

func init_passed_level(current_i:int):
	i=current_i


func _on_NextLevelButton_mouse_entered():
	#播放音效
	$AudioStreamPlayer.stream=SELECT_SFX
	$AudioStreamPlayer.play()

func _on_BackToTutorialStartButton_mouse_entered():
	#播放音效
	$AudioStreamPlayer.stream=SELECT_SFX
	$AudioStreamPlayer.play()


func _on_NextLevelButton_button_down():
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_1
	$AudioStreamPlayer.play()

func _on_BackToTutorialStartButton_button_down():
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_1
	$AudioStreamPlayer.play()
