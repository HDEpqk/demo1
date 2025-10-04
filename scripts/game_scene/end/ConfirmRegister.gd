extends Control


const SELECT_SFX=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Select - 1.mp3str")

const CURSOR_CLICK_1=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Cursor - 1.mp3str")

func _ready():
	self.hide()





func _on_ConfirmButton_pressed():
	self.hide()
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_1
	$AudioStreamPlayer.play()
	$"../UserRegister".show()


func _on_ConfirmButton_mouse_entered():
	#播放音效
	$AudioStreamPlayer.stream=SELECT_SFX
	$AudioStreamPlayer.play()

func _on_CancelButton_pressed():
	self.hide()
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_1
	$AudioStreamPlayer.play()

func _on_CancelButton_mouse_entered():
	#播放音效
	$AudioStreamPlayer.stream=SELECT_SFX
	$AudioStreamPlayer.play()


func _on_ConfirmRegister_visibility_changed():
	get_tree().paused=self.visible

