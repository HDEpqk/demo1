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

onready var combo_label=$ComboLabel
onready var counter_rich_label=$CounterRichLabel
onready var generation_rich_label=$GenerationRichLabel

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
	#订阅克制事件
	EventBus.connect("counter",self,"_on_counter")
	counter_rich_label.hide()
	#订阅被克制事件
	EventBus.connect("anti_counter",self,"_on_anti_counter")
	#订阅玩家生脸谱事件
	EventBus.connect("wuxing_generation_available",self,"_on_wuxing_generation_available")
	#订阅脸谱生玩家事件
	EventBus.connect("anti_wuxing_generation",self,"_on_anti_wuxing_generation")


	generation_rich_label.hide()
	counter_rich_label.bbcode_enabled=true
	generation_rich_label.bbcode_enabled=true
	counter_rich_label.bbcode_enabled=true
	
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

func _on_counter(player_taiji_mode,counter_score):

	match player_taiji_mode:
		GameEnums.TaijiMode.huo:
			counter_rich_label.bbcode_text="[color=#e40000]"+"火"+"[/color]"+"[color=#000000]克[/color]"+"[color=#e6da29]"+"金"+"[/color]"
		GameEnums.TaijiMode.jin:
			counter_rich_label.bbcode_text="[color=#e6da29]"+"金"+"[/color]"+"[color=#000000]克[/color]"+"[color=#28c641]"+"木"+"[/color]"
		GameEnums.TaijiMode.shui:
			counter_rich_label.bbcode_text="[color=#2d93dd]"+"水"+"[/color]"+"[color=#000000]克[/color]"+"[color=#e40000]"+"火"+"[/color]"
		GameEnums.TaijiMode.tu:
			counter_rich_label.bbcode_text="[color=#b36d41]"+"土"+"[/color]"+"[color=#000000]克[/color]"+"[color=#2d93dd]"+"水"+"[/color]"

	counter_rich_label.show()
	var tween = counter_rich_label.get_node("Tween")
	tween.interpolate_property(counter_rich_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_callback(counter_rich_label,2,"hide")
	tween.start()
	

	
func _on_anti_counter(player_taiji_mode,anti_counter_score):

	match player_taiji_mode:
		GameEnums.TaijiMode.huo:
			counter_rich_label.bbcode_text="[color=#e40000]"+"火"+"[/color]"+"被"+"[color=#2d93dd]"+"水"+"[/color]"+"克"
		GameEnums.TaijiMode.jin:
			counter_rich_label.bbcode_text="[color=#e6da29]"+"金"+"[/color]"+"被"+"[color=#e40000]"+"火"+"[/color]"+"克"
		GameEnums.TaijiMode.shui:
			counter_rich_label.bbcode_text="[color=#2d93dd]"+"水"+"[/color]"+"被"+"[color=#b36d41]"+"土"+"[/color]"+"克"
		GameEnums.TaijiMode.tu:
			counter_rich_label.bbcode_text="[color=#b36d41]"+"土"+"[/color]"+"被"+"[color=#28c641]"+"木"+"[/color]"+"克"
		GameEnums.TaijiMode.mu:
			counter_rich_label.bbcode_text="[color=#28c641]"+"木"+"[/color]"+"被"+"[color=#e6da29]"+"金"+"[/color]"+"克"

	counter_rich_label.show()
	var tween = counter_rich_label.get_node("Tween")
	tween.interpolate_property(counter_rich_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_callback(counter_rich_label,2,"hide")
	tween.start()


func _on_wuxing_generation_available(lianpu_data):
	var player_taiji_mode=lianpu_data["player_mode"]
	match player_taiji_mode:
		GameEnums.TaijiMode.mu:
			generation_rich_label.bbcode_text="[color=#28c641]"+"木"+"[/color]"+"生"+"[color=#e40000]"+"火"+"[/color]"
		GameEnums.TaijiMode.jin:
			generation_rich_label.bbcode_text="[color=#e6da29]"+"金"+"[/color]"+"生"+"[color=#2d93dd]"+"水"+"[/color]"
		GameEnums.TaijiMode.shui:
			generation_rich_label.bbcode_text="[color=#2d93dd]"+"水"+"[/color]"+"生"+"[color=#28c641]"+"木"+"[/color]"
		GameEnums.TaijiMode.tu:
			generation_rich_label.bbcode_text="[color=#b36d41]"+"土"+"[/color]"+"生"+"[color=#e6da29]"+"金"+"[/color]"

	generation_rich_label.show()
	var tween = generation_rich_label.get_node("Tween")
	tween.interpolate_property(generation_rich_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_callback(generation_rich_label,2,"hide")
	tween.start()

func _on_anti_wuxing_generation(player_taiji_mode):
	match player_taiji_mode:
		GameEnums.TaijiMode.mu:
			generation_rich_label.bbcode_text="[color=#28c641]"+"木"+"[/color]"+"被"+"[color=#2d93dd]"+"水"+"[/color]"+"生"
		GameEnums.TaijiMode.huo:
			generation_rich_label.bbcode_text="[color=#e40000]"+"火"+"[/color]"+"被"+"[color=#28c641]"+"木"+"[/color]"+"生"
		GameEnums.TaijiMode.shui:
			generation_rich_label.bbcode_text="[color=#2d93dd]"+"水"+"[/color]"+"被"+"[color=#e6da29]"+"金"+"[/color]"+"生"
		GameEnums.TaijiMode.tu:
			generation_rich_label.bbcode_text="[color=#b36d41]"+"土"+"[/color]"+"被"+"[color=#e40000]"+"火"+"[/color]"+"生"

	generation_rich_label.show()
	var tween = generation_rich_label.get_node("Tween")
	tween.interpolate_property(generation_rich_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_callback(generation_rich_label,2,"hide")
	tween.start()
