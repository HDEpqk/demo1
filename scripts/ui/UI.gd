# UI.gd
extends CanvasLayer

onready var energy_calibration=$EnergyCalibration
onready var pause_btn=$PauseButton
onready var pause_panel=$PausePanel
onready var main_countdown_label=$MainCountdownLabel

func _ready():
	pause_btn.connect("pressed", self, "_on_pauseBtn_pressed")
	#注册面板
	UiMgr.register_control("PausePanel",pause_panel)
	#注册MainCountdownLabel
	UiMgr.register_control("MainCountdownLabel",main_countdown_label)
	#注册EnergyCalibration
	UiMgr.register_control("EnergyCalibration",energy_calibration)
	

	
func _on_pauseBtn_pressed():
	UiMgr.show_control("PausePanel")


