extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TutorialBtn_pressed():
	$"../Panel".show()


func _on_TutorialBtn_button_down():
	#按下btn时候把btn变小
	self.rect_scale=Vector2(1,1)


func _on_TutorialBtn_button_up():
	#松开btn时候把btn变回原来大小
	self.rect_scale=Vector2(1.1,1.1)


func _on_TutorialBtn_mouse_entered():
	#鼠标进入让btn变大
	self.rect_scale=Vector2(1.1,1.1)


func _on_TutorialBtn_mouse_exited():
	self.rect_scale=Vector2(1,1)
