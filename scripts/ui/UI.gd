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
onready var multiple_timer_Label=$TotalMultipleLabel/MultipleTimer/MultipleTimerLabel
onready var multiple_timer=$TotalMultipleLabel/MultipleTimer

onready var accelerate_spawn_label=$AccelerateSpawnLabel
onready var accelerate_spawn_timer_Label=$AccelerateSpawnLabel/AccelerateSpawnTimer/AccelerateSpawnTimerLabel
onready var accelerate_spawn_timer=$AccelerateSpawnLabel/AccelerateSpawnTimer

onready var decelerate_spawn_label=$DecelerateSpawnLabel
onready var decelerate_spawn_timer_Label=$DecelerateSpawnLabel/DecelerateeSpawnTimer/DecelerateSpawnTimerLabel
onready var decelerate_spawn_timer=$DecelerateSpawnLabel/DecelerateeSpawnTimer

onready var crazy_time_timer=$CrazyTime/CrazyTimeTimer

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
	multiple_timer_Label.visible=false
	multiple_timer_Label.self_modulate=Color("#69db1b")
	#订阅开始加速生成的事件
	EventBus.connect("accelerate_spawn_begin", self, "_on_accelerate_spawn_begin")
	accelerate_spawn_label.visible=false
	accelerate_spawn_timer_Label.visible=false
	accelerate_spawn_timer_Label.self_modulate=Color.firebrick
	#订阅开始减速生成的事件
	EventBus.connect("decelerate_spawn_begin", self, "_on_decelerate_spawn_begin")
	decelerate_spawn_label.visible=false
	decelerate_spawn_timer_Label.visible=false
	decelerate_spawn_timer_Label.self_modulate=Color.skyblue
	#订阅开始疯狂时间的事件
	EventBus.connect("crazy_time_begin",self,"_on_crazy_time_begin")
	#隐藏crazyTime背景
	crazy_time_bg.visible=false
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
	total_score_label.text="分数:"+str(new_value)
	#DebugUtils.log("分数UI已更新")

func _on_global_multiple_changed(new_value: int,isTiming:bool,duration:float):
	var multiple=clamp(new_value,1,8)
	total_multipleLabel.text="倍数:X"+str(multiple)
	if isTiming:
		multiple_timer_Label.visible=true
		current_multiple_time=duration
		multiple_timer_Label.text="%d" %current_multiple_time	
		multiple_timer.start()



func _on_MultipleTimer_timeout():
	current_multiple_time-=1
	multiple_timer_Label.text="%d" %current_multiple_time
	if current_multiple_time<=0:
		multiple_timer.stop()
		multiple_timer_Label.visible=false
		#倒计时结束后要把倍数调回去
		Global.set_lianpu_multiple(1)
		EventBus.fire_event_3param("global_multiple_changed",Global.get_multiple(),false,5)
		total_multipleLabel.text="倍数:X"+str(Global.get_multiple())

func _on_accelerate_spawn_begin(duration):
	DebugUtils.log("begin accelerate!:UI")
	#隐藏减速文本
	decelerate_spawn_label.visible=false
	decelerate_spawn_timer_Label.visible=false
	#显示加速文本
	accelerate_spawn_label.text="生成加速中"
	accelerate_spawn_label.visible=true
	accelerate_spawn_timer_Label.text=str(duration)
	accelerate_spawn_timer_Label.visible=true
	
	current_accelerate_spawn_time=duration
	accelerate_spawn_timer.start()

func _on_AccelerateSpawnTimer_timeout():
	current_accelerate_spawn_time-=1
	accelerate_spawn_timer_Label.text="%d" %current_accelerate_spawn_time
	if current_accelerate_spawn_time<=0:
		accelerate_spawn_timer.stop()
		accelerate_spawn_label.visible=false
		accelerate_spawn_timer_Label.visible=false
		EventBus.fire_event("accelerate_spawn_end")

func _on_decelerate_spawn_begin(duration):
	DebugUtils.log("begin decelerate:UI!")
	#隐藏加速文本
	accelerate_spawn_label.visible=false
	accelerate_spawn_timer_Label.visible=false
	#显示减速文本
	decelerate_spawn_label.text="生成减速中"
	decelerate_spawn_label.visible=true
	decelerate_spawn_timer_Label.text=str(duration)
	decelerate_spawn_timer_Label.visible=true

	current_decelerate_spawn_time=duration
	decelerate_spawn_timer.start()


func _on_DecelerateeSpawnTimer_timeout():
	current_decelerate_spawn_time-=1
	decelerate_spawn_timer_Label.text="%d" %current_decelerate_spawn_time
	if current_decelerate_spawn_time<=0:
		decelerate_spawn_timer.stop()
		decelerate_spawn_label.visible=false
		decelerate_spawn_timer_Label.visible=false
		EventBus.fire_event("decelerate_spawn_end")

func _on_crazy_time_begin(duration):
	current_crazy_time=duration
	crazy_time_timer.start()
	#显示crazy_time_bg背景
	crazy_time_bg.color=Color.gold
	crazy_time_bg.color.a=0.4
	crazy_time_bg.visible=true
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
		crazy_time_bg.visible=false
		EventBus.fire_event("crazy_time_end")
	
