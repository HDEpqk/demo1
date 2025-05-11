# UI.gd
extends CanvasLayer

onready var energy_calibration=$EnergyCalibration
onready var pause_btn=$PauseButton
onready var pause_panel=$PausePanel
onready var main_countdown_label=$MainCountdownLabel
onready var total_score_label=$TotalScoreLabel

func _ready():
	pause_btn.connect("pressed", self, "_on_pauseBtn_pressed")
	#注册面板
	UiMgr.register_control("PausePanel",pause_panel)
	#注册MainCountdownLabel
	UiMgr.register_control("MainCountdownLabel",main_countdown_label)
	#注册EnergyCalibration
	UiMgr.register_control("EnergyCalibration",energy_calibration)
	#注册TotalScoreLabel
	UiMgr.register_control("TotalScoreLabel",total_score_label)
	#订阅玩家能量更新的事件
	EventBus.connect("global_energy_changed", self, "_update_energy_bar")
	#订阅玩家分数更新的事件
	EventBus.connect("global_score_changed", self, "_update_score_label")

func _on_pauseBtn_pressed():
	UiMgr.show_control("PausePanel")

func _update_energy_bar(new_value: float):
	energy_calibration.set_energy(new_value)
	#DebugUtils.log("能量UI已更新")

func _update_score_label(new_value: float):
	total_score_label.text="总分数:"+str(new_value)
	#DebugUtils.log("分数UI已更新")


