extends Control


const SELECT_SFX=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Select - 1.mp3str")
const CURSOR_CLICK_1=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Cursor - 1.mp3str")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




func _on_TutorialBtn_pressed():
	SceneMgr.change_scene("res://scene/tutorial/TutorialStartScene.tscn")


func _on_TutorialBtn_button_down():
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_1
	$AudioStreamPlayer.play()
	#按下btn时候把btn变小
	self.rect_scale=Vector2(1,1)


func _on_TutorialBtn_button_up():
	#松开btn时候把btn变回原来大小
	self.rect_scale=Vector2(1.1,1.1)


func _on_TutorialBtn_mouse_entered():
	#鼠标进入让btn变大
	self.rect_scale=Vector2(1.1,1.1)
	#播放音效
	$AudioStreamPlayer.stream=SELECT_SFX
	$AudioStreamPlayer.play()

func _on_TutorialBtn_mouse_exited():
	self.rect_scale=Vector2(1,1)
