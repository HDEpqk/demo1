# UI.gd
extends CanvasLayer

onready var viewport_size = get_viewport().size
onready var bg:TextureRect=$BG
onready var crazy_time_bg=$CrazyTimeBG
onready var energy_calibration=$EnergyCalibration

onready var pause_btn=$PauseButton
onready var pause_panel=$PausePanel

onready var main_countdown_label=$MainCountdownLabel

onready var total_score_label=$TotalScoreLabel

onready var total_multipleLabel=$TotalMultipleLabel
onready var multiple_timer_Label=$TotalMultipleLabel/MultipleTimerLabel
onready var multiple_timer=$TotalMultipleLabel/MultipleTimer
onready var multiple_timer_icon=$TotalMultipleLabel/MultipleCountdownIcon


onready var accelerate_spawn_label=$AccelerateSpawnLabel
onready var accelerate_spawn_timer_Label=$AccelerateSpawnLabel/AccelerateSpawnTimerLabel
onready var accelerate_spawn_timer=$AccelerateSpawnLabel/AccelerateSpawnTimer
onready var accelerate_spawn_timer_icon=$AccelerateSpawnLabel/AccelerateSpawnCountdownIcon


onready var decelerate_spawn_label=$DecelerateSpawnLabel
onready var decelerate_spawn_timer_Label=$DecelerateSpawnLabel/DecelerateSpawnTimerLabel
onready var decelerate_spawn_timer=$DecelerateSpawnLabel/DecelerateeSpawnTimer
onready var decelerate_spawn_timer_icon=$DecelerateSpawnLabel/DecelerateSpawnCountdownIcon

onready var crazy_time_timer=$CrazyTime/CrazyTimeTimer

onready var combo_label=$ComboLabel
onready var counter_label=$CounterLabel

var current_multiple_time:float=0

var current_accelerate_spawn_time:float=0

var current_decelerate_spawn_time:float=0

var current_crazy_time:float=0

#var is_multiple_timer_timming:bool=false#加倍计时器是否在倒计时

func _ready():
	pause_btn.connect("pressed", self, "_on_pauseBtn_pressed")
	#注册面板
	#UiMgr.register_control("PausePanel",pause_panel)
	#注册MainCountdownLabel
	#UiMgr.register_control("MainCountdownLabel",main_countdown_label)
	#注册EnergyCalibration
	#UiMgr.register_control("EnergyCalibration",energy_calibration)
	#注册TotalScoreLabel
	#UiMgr.register_control("TotalScoreLabel",total_score_label)
	#订阅玩家能量更新的事件
	EventBus.connect("global_energy_changed", self, "_update_energy_bar")
	#订阅玩家分数更新的事件
	EventBus.connect("global_score_changed", self, "_update_score_label")
	#订阅玩家倍数更新的事件
	EventBus.connect("global_multiple_changed", self, "_on_global_multiple_changed")
	multiple_timer_Label.hide()
	multiple_timer_Label.self_modulate=Color("#69db1b")
	multiple_timer_icon.hide()
	#订阅开始加速生成的事件
	EventBus.connect("accelerate_spawn_begin", self, "_on_accelerate_spawn_begin")
	accelerate_spawn_label.hide()
	accelerate_spawn_label.self_modulate=Color.firebrick
	accelerate_spawn_timer_Label.hide()
	accelerate_spawn_timer_Label.self_modulate=Color.firebrick
	accelerate_spawn_timer_icon.hide()
	#订阅开始减速生成的事件
	EventBus.connect("decelerate_spawn_begin", self, "_on_decelerate_spawn_begin")
	decelerate_spawn_label.hide()
	decelerate_spawn_label.self_modulate=Color.skyblue
	decelerate_spawn_timer_Label.hide()
	decelerate_spawn_timer_Label.self_modulate=Color.skyblue
	decelerate_spawn_timer_icon.hide()
	#订阅开始疯狂时间的事件
	EventBus.connect("crazy_time_begin",self,"_on_crazy_time_begin")
	#隐藏crazyTime背景
	crazy_time_bg.hide()
	#订阅连击事件
	EventBus.connect("combo",self,"_on_combo")
	combo_label.hide()
	#订阅克制事件
	EventBus.connect("counter",self,"_on_counter")
	counter_label.hide()
	#订阅被克制事件
	EventBus.connect("anti_counter",self,"_on_anti_counter")
	#设置背景的缩放
#	var texture_size = bg.get_size()
#	var scale_x = viewport_size.x / texture_size.x
#	var scale_y = viewport_size.y / texture_size.y
#	bg.rect_scale = Vector2(scale_x, scale_y)
	
func _on_pauseBtn_pressed():
	#UiMgr.show_control("PausePanel")
	pause_panel.show()

func _update_energy_bar(new_value: float):
	energy_calibration.set_energy(new_value)
	#DebugUtils.log("能量UI已更新")

func _update_score_label(new_value: float):
	total_score_label.text="得分:"+str(new_value)
	#DebugUtils.log("分数UI已更新")

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

func _on_accelerate_spawn_begin(duration):
	DebugUtils.log("begin accelerate!:UI")
	#隐藏减速文本
	decelerate_spawn_label.hide()
	decelerate_spawn_timer_Label.hide()
	decelerate_spawn_timer_icon.hide()
	#显示加速文本
	accelerate_spawn_label.text="加速..."
	accelerate_spawn_label.show()
	accelerate_spawn_timer_Label.text=str(duration)
	accelerate_spawn_timer_Label.show()
	accelerate_spawn_timer_icon.show()
	
	current_accelerate_spawn_time=duration
	accelerate_spawn_timer.start()

func _on_AccelerateSpawnTimer_timeout():
	current_accelerate_spawn_time-=1
	accelerate_spawn_timer_Label.text="%d" %current_accelerate_spawn_time
	if current_accelerate_spawn_time<=0:
		accelerate_spawn_timer.stop()
		accelerate_spawn_label.hide()
		accelerate_spawn_timer_Label.hide()
		accelerate_spawn_timer_icon.hide()
		EventBus.fire_event("accelerate_spawn_end")

func _on_decelerate_spawn_begin(duration):
	DebugUtils.log("begin decelerate:UI!")
	#隐藏加速文本
	accelerate_spawn_label.hide()
	accelerate_spawn_timer_Label.hide()
	accelerate_spawn_timer_icon.hide()
	#显示减速文本
	decelerate_spawn_label.text="减速..."
	decelerate_spawn_label.show()
	decelerate_spawn_timer_Label.text=str(duration)
	decelerate_spawn_timer_Label.show()
	decelerate_spawn_timer_icon.show()

	current_decelerate_spawn_time=duration
	decelerate_spawn_timer.start()


func _on_DecelerateeSpawnTimer_timeout():
	current_decelerate_spawn_time-=1
	decelerate_spawn_timer_Label.text="%d" %current_decelerate_spawn_time
	if current_decelerate_spawn_time<=0:
		decelerate_spawn_timer.stop()
		decelerate_spawn_label.hide()
		decelerate_spawn_timer_Label.hide()
		decelerate_spawn_timer_icon.hide()
		EventBus.fire_event("decelerate_spawn_end")

func _on_crazy_time_begin(duration):
	current_crazy_time=duration
	crazy_time_timer.start()
	#显示crazy_time_bg背景
	crazy_time_bg.color=Color.gold
	crazy_time_bg.color.a=0.4
	crazy_time_bg.show()
	DebugUtils.log("显示BG,当前BG的visible="+str($BG.visible))
	#开始加速
	EventBus.fire_event("accelerate_spawn_begin",current_crazy_time)
	#开始加倍
	Global.set_lianpu_multiple(2)
	EventBus.fire_event_3param("global_multiple_changed",Global.get_multiple(),true,current_crazy_time)

func _on_CrazyTimeTimer_timeout():
	current_crazy_time-=1
	if current_crazy_time<=0:
		crazy_time_timer.stop()
		#隐藏crazy_time_bg背景
		crazy_time_bg.hide()
		EventBus.fire_event("crazy_time_end")

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

func _on_counter(player_taiji_mode):
	counter_label.bbcode_enabled=true
	match player_taiji_mode:
		GameEnums.TaijiMode.huo:
			counter_label.bbcode_text="[color=#e40000]"+"火"+"[/color]"+"克"+"[color=#e6da29]"+"金"+"[/color]"
		GameEnums.TaijiMode.jin:
			counter_label.bbcode_text="[color=#e6da29]"+"金"+"[/color]"+"克"+"[color=#28c641]"+"木"+"[/color]"
		GameEnums.TaijiMode.shui:
			counter_label.bbcode_text="[color=#2d93dd]"+"水"+"[/color]"+"克"+"[color=#e40000]"+"火"+"[/color]"
		GameEnums.TaijiMode.tu:
			counter_label.bbcode_text="[color=#b36d41]"+"土"+"[/color]"+"克"+"[color=#2d93dd]"+"水"+"[/color]"

	counter_label.show()
	var tween = counter_label.get_node("Tween")
	tween.interpolate_property(counter_label, "rect_scale",
	Vector2(4, 4), Vector2(3, 3), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_callback(counter_label,1,"hide")
	tween.start()
	
func _on_anti_counter(player_taiji_mode):
	counter_label.bbcode_enabled=true
	match player_taiji_mode:
		GameEnums.TaijiMode.huo:
			counter_label.bbcode_text="[color=#e40000]"+"火"+"[/color]"+"被"+"[color=#2d93dd]"+"水"+"[/color]"+"克"
		GameEnums.TaijiMode.jin:
			counter_label.bbcode_text="[color=#e6da29]"+"金"+"[/color]"+"被"+"[color=#e40000]"+"火"+"[/color]"+"克"
		GameEnums.TaijiMode.shui:
			counter_label.bbcode_text="[color=#2d93dd]"+"水"+"[/color]"+"被"+"[color=#b36d41]"+"土"+"[/color]"+"克"
		GameEnums.TaijiMode.tu:
			counter_label.bbcode_text="[color=#b36d41]"+"土"+"[/color]"+"被"+"[color=#28c641]"+"木"+"[/color]"+"克"

	counter_label.show()
	var tween = counter_label.get_node("Tween")
	tween.interpolate_property(counter_label, "rect_scale",
	Vector2(4, 4), Vector2(3, 3), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_callback(counter_label,1,"hide")
	tween.start()
