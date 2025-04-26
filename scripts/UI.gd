# UI.gd
extends CanvasLayer

onready var energy_calibration=$EnergyCalibration
onready var pause_panel=$PausePanel
onready var pause_btn=$PauseButtonParent/PauseButton

func _ready():
	pause_btn.connect("pressed", self, "_on_pauseBtn_pressed")
	pause_btn.anchor_right=1
	pause_btn.anchor_top=1
	var viewport_size=get_viewport().size
	$PauseButtonParent.position.x=viewport_size.x-pause_btn.rect_size.x

	
func update_energy(new_energy: float):
	energy_calibration.set_value(new_energy)

	
func _on_pauseBtn_pressed():
	pause_panel.show_panel()


