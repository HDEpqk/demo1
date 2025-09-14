extends CanvasLayer

onready var viewport_size = get_viewport().size


onready var pause_btn=$PauseButton
onready var pause_panel=$PausePanel





func _ready():
	pause_btn.connect("pressed", self, "_on_pauseBtn_pressed")

	
func _on_pauseBtn_pressed():
	#UiMgr.show_control("PausePanel")
	pause_panel.show()






