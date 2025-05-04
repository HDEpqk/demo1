# UI.gd
extends CanvasLayer

onready var energy_calibration=$EnergyCalibration
onready var pause_btn=$PauseButton
onready var pause_panel=$PausePanel
onready var setting_panel=$SettingPanel
onready var main_countdown_label=$MainCountdownLabel

func _ready():
	pause_btn.connect("pressed", self, "_on_pauseBtn_pressed")
	#注册面板
	UiMgr.register_control("PausePanel",pause_panel)
	UiMgr.register_control("SettingPanel",setting_panel)
	#注册MainCountdownLabel
	UiMgr.register_control("MainCountdownLabel",main_countdown_label)
	
func update_energy(new_energy: float):
	energy_calibration.set_value(new_energy)

	
func _on_pauseBtn_pressed():
	UiMgr.show_control("PausePanel")


