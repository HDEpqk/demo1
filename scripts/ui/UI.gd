# UI.gd
extends CanvasLayer

onready var viewport_size = GuiAutoload.viewport_size

onready var crazy_time_bg=$CrazyTimeBG
onready var energy_calibration=$EnergyCalibration

onready var pause_btn=$PauseButton
onready var pause_panel=$PausePanel




#加倍相关
onready var total_multipleLabel=$TotalMultipleLabel
onready var multiple_timer_Label=$TotalMultipleLabel/MultipleTimerLabel
onready var multiple_timer=$TotalMultipleLabel/MultipleTimer
onready var multiple_timer_icon=$TotalMultipleLabel/MultipleCountdownIcon

#加速相关
onready var accelerate_spawn_label=$AccelerateSpawnLabel
onready var accelerate_spawn_timer_Label=$AccelerateSpawnLabel/AccelerateSpawnTimerLabel
onready var accelerate_spawn_timer=$AccelerateSpawnLabel/AccelerateSpawnTimer
onready var accelerate_spawn_timer_icon=$AccelerateSpawnLabel/AccelerateSpawnCountdownIcon

#减速相关
onready var decelerate_spawn_label=$DecelerateSpawnLabel
onready var decelerate_spawn_timer_Label=$DecelerateSpawnLabel/DecelerateSpawnTimerLabel
onready var decelerate_spawn_timer=$DecelerateSpawnLabel/DecelerateeSpawnTimer
onready var decelerate_spawn_timer_icon=$DecelerateSpawnLabel/DecelerateSpawnCountdownIcon

#得分相关
onready var total_score_rich_label=$TotalScore/TotalScoreLabel
onready var base_award_rich_label=$TotalScore/ScoreDetail/BaseAward
onready var two_combo_award_rich_label=$TotalScore/ScoreDetail/TwoComboAward
onready var three_combo_award_rich_label=$TotalScore/ScoreDetail/ThreeComboAward
onready var counter_award_rich_label=$TotalScore/ScoreDetail/CounterAward
onready var anti_counter_punishment_rich_label=$TotalScore/ScoreDetail/AntiCounterPunishment

#其他
onready var crazy_time_timer=$CrazyTime/CrazyTimeTimer
onready var combo_label=$ComboLabel
onready var counter_rich_label=$CounterRichLabel
onready var generation_rich_label=$GenerationRichLabel

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
	counter_rich_label.hide()
	#订阅被克制事件
	EventBus.connect("anti_counter",self,"_on_anti_counter")
	#订阅消灭脸谱事件
	EventBus.connect("kill_lianpu_award",self,"_on_kill_lianpu_award")
	#订阅连击奖励事件
	EventBus.connect("combo_award",self,"_on_combo_award")
	#订阅玩家生脸谱事件
	EventBus.connect("wuxing_generation_available",self,"_on_wuxing_generation_available")
	#订阅脸谱生玩家事件
	EventBus.connect("anti_wuxing_generation",self,"_on_anti_wuxing_generation")
	base_award_rich_label.hide()
	two_combo_award_rich_label.hide()
	three_combo_award_rich_label.hide()
	counter_award_rich_label.hide()
	generation_rich_label.hide()
	anti_counter_punishment_rich_label.hide()
	total_score_rich_label.bbcode_enabled=true
	two_combo_award_rich_label.bbcode_enabled=true
	three_combo_award_rich_label.bbcode_enabled=true
	counter_rich_label.bbcode_enabled=true
	generation_rich_label.bbcode_enabled=true
	counter_award_rich_label.bbcode_enabled=true
	counter_rich_label.bbcode_enabled=true
	anti_counter_punishment_rich_label.bbcode_enabled=true
	base_award_rich_label.bbcode_enabled=true

	
func _on_pauseBtn_pressed():
	pause_panel.show()
	var tween = pause_btn.get_node("Tween")
	tween.interpolate_property(pause_btn, "rect_scale",
	Vector2(1.2, 1.2), Vector2(1, 1), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
func _update_energy_bar(new_value: float):
	energy_calibration.set_energy(new_value)
	#DebugUtils.log("能量UI已更新")

func _update_score_label(new_value: float):
	total_score_rich_label.set_score(new_value)
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
	accelerate_spawn_label.text="加速生成"
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
	decelerate_spawn_label.text="减速生成"
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
	
func _on_combo_award(combo_score,combo_count):

	match combo_count:
		2:
			two_combo_award_rich_label.bbcode_text="二连击奖励:+"+str(combo_score)#显示连击得分详情
			two_combo_award_rich_label.show()
			var tween = two_combo_award_rich_label.get_node("Tween")
			tween.interpolate_property(two_combo_award_rich_label, "rect_scale",
			Vector2(3, 3), Vector2(2, 2), 0.1,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.interpolate_callback(two_combo_award_rich_label,2,"hide")
			tween.start()
		3:
			three_combo_award_rich_label.bbcode_text="三连击奖励:+"+str(combo_score)#显示连击得分详情
			three_combo_award_rich_label.show()
			var tween = three_combo_award_rich_label.get_node("Tween")
			tween.interpolate_property(three_combo_award_rich_label, "rect_scale",
			Vector2(3, 3), Vector2(2, 2), 0.1,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.interpolate_callback(three_combo_award_rich_label,2,"hide")
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
	
	#克制加分详情
	counter_award_rich_label.bbcode_text="克制奖励:+"+str(counter_score)
	counter_award_rich_label.show()
	var tween2 = counter_award_rich_label.get_node("Tween")
	tween2.interpolate_property(counter_award_rich_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween2.interpolate_callback(counter_award_rich_label,2,"hide")
	tween2.start()
	
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
	
	#被克制减分详情
	anti_counter_punishment_rich_label.bbcode_text="被克制惩罚:-"+str(anti_counter_score)
	anti_counter_punishment_rich_label.show()
	var tween2 = anti_counter_punishment_rich_label.get_node("Tween")
	tween2.interpolate_property(anti_counter_punishment_rich_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween2.interpolate_callback(anti_counter_punishment_rich_label,2,"hide")
	tween2.start()

func _on_kill_lianpu_award(base_score):
	base_award_rich_label.bbcode_text="消灭脸谱奖励:+"+str(base_score)
	base_award_rich_label.show()
	var tween = base_award_rich_label.get_node("Tween")
	tween.interpolate_property(base_award_rich_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_callback(base_award_rich_label,2,"hide")
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
