# UI.gd
extends CanvasLayer

onready var energy_calibration=$EnergyCalibration
onready var pause_btn=$PauseButtonParent/PauseButton
onready var pause_panel=$PausePanel
onready var setting_panel=$SettingPanel

func _ready():
	pause_btn.connect("pressed", self, "_on_pauseBtn_pressed")
	pause_btn.anchor_right=1
	pause_btn.anchor_top=1
	var viewport_size=get_viewport().size
	$PauseButtonParent.position.x=viewport_size.x-pause_btn.rect_size.x
	#注册面板
	UiMgr.register_control("PausePanel",pause_panel)
	UiMgr.register_control("SettingPanel",setting_panel)
	
func update_energy(new_energy: float):
	energy_calibration.set_value(new_energy)

	
func _on_pauseBtn_pressed():
	UiMgr.show_control("PausePanel")


