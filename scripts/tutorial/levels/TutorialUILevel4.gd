extends CanvasLayer

onready var viewport_size = get_viewport().size

onready var crazy_time_bg=$CrazyTimeBG
onready var energy_calibration=$EnergyCalibration

onready var pause_btn=$PauseButton
onready var pause_panel=$PausePanel



#加倍相关
onready var total_multipleLabel=$TotalMultipleLabel
onready var multiple_timer_Label=$TotalMultipleLabel/MultipleTimerLabel
onready var multiple_timer=$TotalMultipleLabel/MultipleTimer
onready var multiple_timer_icon=$TotalMultipleLabel/MultipleCountdownIcon
var current_multiple_time:float=0

#连击
onready var combo_label=$ComboLabel


func _ready():
	pause_btn.connect("pressed", self, "_on_pauseBtn_pressed")
	#订阅玩家能量更新的事件
	EventBus.connect("global_energy_changed", self, "_update_energy_bar")

	#订阅玩家倍数更新的事件
	EventBus.connect("global_multiple_changed", self, "_on_global_multiple_changed")
	multiple_timer_Label.hide()
	multiple_timer_Label.self_modulate=Color("#69db1b")
	multiple_timer_icon.hide()
	
	#订阅连击事件
	EventBus.connect("combo",self,"_on_combo")
	combo_label.hide()

	
func _on_pauseBtn_pressed():
	#UiMgr.show_control("PausePanel")
	pause_panel.show()
	var tween = pause_btn.get_node("Tween")
	tween.interpolate_property(pause_btn, "rect_scale",
	Vector2(1.2, 1.2), Vector2(1, 1), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
func _update_energy_bar(new_value: float):
	energy_calibration.set_energy(new_value)
	#DebugUtils.log("能量UI已更新")



func _on_global_multiple_changed(new_value: int,isTiming:bool,duration:float):
	var multiple=clamp(new_value,1,8)
	total_multipleLabel.text="倍数:×"+str(multiple)
	if multiple==1:
		total_multipleLabel.self_modulate=Color.white
	else:
		total_multipleLabel.self_modulate=Color("#69db1b")
	if isTiming:
		multiple_timer_Label.show()
		multiple_timer_icon.show()
		current_multiple_time=duration
		multiple_timer_Label.text="%d" %current_multiple_time	
		multiple_timer.start()



func _on_MultipleTimer_timeout():
	current_multiple_time-=1
	multiple_timer_Label.text="%d" %current_multiple_time
	if current_multiple_time<=0:
		multiple_timer.stop()
		multiple_timer_Label.hide()
		multiple_timer_icon.hide()
		#倒计时结束后要把倍数调回去
		Global.set_lianpu_multiple(1)
		EventBus.fire_event_3param("global_multiple_changed",Global.get_multiple(),false,5)
		total_multipleLabel.text="倍数:×"+str(Global.get_multiple())


func _on_combo(combo_count,combo_timeout,lianpu_taiji_mode):
	match lianpu_taiji_mode:
		GameEnums.TaijiMode.huo:
			combo_label.self_modulate=Color("#e40000")
		GameEnums.TaijiMode.jin:
			combo_label.self_modulate=Color("#e6da29")
		GameEnums.TaijiMode.mu:
			combo_label.self_modulate=Color("#28c641")
		GameEnums.TaijiMode.shui:
			combo_label.self_modulate=Color("#2d93dd")
		GameEnums.TaijiMode.tu:
			combo_label.self_modulate=Color("#b36d41")
	var modulate=combo_label.self_modulate
	match combo_count:
		1:
			combo_label.self_modulate=modulate.darkened(0.4)
		2:
			combo_label.self_modulate=modulate.darkened(0.2)
		_:
			combo_label.self_modulate=modulate

	combo_label.text="连击×%d" % combo_count
	combo_label.show()
	var tween = combo_label.get_node("Tween")
	tween.interpolate_property(combo_label, "rect_scale",
	Vector2(4, 4), Vector2(3, 3), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_callback(combo_label,combo_timeout,"hide")
	tween.start()
