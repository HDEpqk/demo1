extends Control

# 回到开始场景按钮
onready var back_to_start_button=$PanelContainer/MarginContainer/VBoxContainer/BackToStartButton
# 返回游戏按钮
onready var resume_game_button=$PanelContainer/MarginContainer/VBoxContainer/ResumeGameButton
#滑动条
onready var slider=$PanelContainer/MarginContainer/VBoxContainer/HSlider
#滑动条文本
onready var slider_label=$PanelContainer/MarginContainer/VBoxContainer/HSlider/Label

func _ready():
	#初始隐藏面板
	#UiMgr.hide_control("PausePanel")
	self.hide()

	# 连接按钮信号
	back_to_start_button.connect("pressed", self, "_on_BackToStartButton_pressed")
	resume_game_button.connect("pressed", self, "_on_ResumeGameButton_pressed")

	var value=DataMgr.get_setting("user","wuxing_calibration_rect_scale")
	slider.value=value
	slider_label.text=str(value)

func _input(event):
	# 检查是否按下了绑定的“toggle_pause”动作对应的按键
	if Input.is_action_just_pressed("ui_pause"):
		toggle_pause_panel()

func toggle_pause_panel():
	if !get_tree().paused:
		# 显示暂停面板
		self.show()
	else:
		# 隐藏暂停面板
		self.hide()

func _on_BackToStartButton_pressed():
	DebugUtils.log("_on_BackToStartButton_pressed")
	#UiMgr.hide_control("PausePanel")
	self.hide()
	get_tree().change_scene("res://scene/game_scene/start/StartScene.tscn")

func _on_ResumeGameButton_pressed():
	DebugUtils.log("_on_ResumeGameButton_pressed")
	#UiMgr.hide_control("PausePanel")
	self.hide()
	
func _on_PausePanel_visibility_changed():
	get_tree().paused=visible



func _on_HSlider_value_changed(value):
	EventBus.fire_event("change_wuxing_calibration_rectscale",value)
	slider_label.text=str(value)
