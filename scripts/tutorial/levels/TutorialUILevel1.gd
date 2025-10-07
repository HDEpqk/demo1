extends CanvasLayer

onready var viewport_size = get_viewport().size


onready var pause_btn=$PauseButton
onready var pause_panel=$PausePanel





func _ready():
	pause_btn.connect("pressed", self, "_on_pauseBtn_pressed")

	
func _on_pauseBtn_pressed():
	#UiMgr.show_control("PausePanel")
	pause_panel.show()
	var tween = pause_btn.get_node("Tween")
	tween.interpolate_property(pause_btn, "rect_scale",
	Vector2(1.2, 1.2), Vector2(1, 1), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()





