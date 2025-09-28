extends Control


var elements_dic:={
	GameEnums.TaijiMode.jin:{"count":0,"is_current_used":false},
	GameEnums.TaijiMode.mu:{"count":0,"is_current_used":false},
	GameEnums.TaijiMode.shui:{"count":0,"is_current_used":false},
	GameEnums.TaijiMode.huo:{"count":0,"is_current_used":false},
	GameEnums.TaijiMode.tu:{"count":0,"is_current_used":false}
	}

#ui相关
onready var black_color=Color.black
onready var white_color=Color.white

onready var jin_count_label=$JinControl/CountLabel
onready var jin_count_label_tween=$JinControl/CountLabel/Tween
onready var jin_key_label=$JinControl/KeyLabel
onready var jin_color=Color("#e6da29")

onready var mu_count_label=$MuControl/CountLabel
onready var mu_count_label_tween=$MuControl/CountLabel/Tween
onready var mu_key_label=$MuControl/KeyLabel
onready var mu_color=Color("#28c641")

onready var shui_count_label=$ShuiControl/CountLabel
onready var shui_count_label_tween=$ShuiControl/CountLabel/Tween
onready var shui_key_label=$ShuiControl/KeyLabel
onready var shui_color=Color("#2d93dd")

onready var huo_count_label=$HuoControl/CountLabel
onready var huo_count_label_tween=$HuoControl/CountLabel/Tween
onready var huo_key_label=$HuoControl/KeyLabel
onready var huo_color=Color("#e40000")

onready var tu_count_label=$TuControl/CountLabel
onready var tu_count_label_tween=$TuControl/CountLabel/Tween
onready var tu_key_label=$TuControl/KeyLabel
onready var tu_color=Color("#b36d41")



func _ready():
	#获取玩家保存的ui设置
	var value=DataMgr.get_setting("user","wuxing_calibration_rect_scale")
	self.rect_scale=Vector2(value,value)	
	
	EventBus.connect("global_taiji_mode_changed",self,"_on_global_taiji_mode_changed")
	EventBus.connect("use_wuxing",self,"_on_use_wuxing")
	EventBus.connect("mu_protect_close",self,"_on_mu_protect_close")
	EventBus.connect("anti_counter",self,"_on_anti_counter")
	EventBus.connect("anti_wuxing_generation",self,"_on_anti_wuxing_generation")
	EventBus.connect("wuxing_generation",self,"_on_wuxing_generation")
	EventBus.connect("change_wuxing_calibration_rectscale",self,"_on_change_wuxing_calibration_rectscale")
	
	
func _input(event):
	if !(event is InputEventKey):return
	if event.pressed and event.scancode == KEY_Q:
		jin_key_label.self_modulate=jin_color
		if elements_dic[GameEnums.TaijiMode.jin]["count"]>0:
			EventBus.fire_event_3param("global_taiji_mode_changed",GameEnums.TaijiMode.jin,Global.taiji_mode,false)
	elif !event.pressed and event.scancode == KEY_Q:
		jin_key_label.self_modulate=black_color
		
	if event.pressed and event.scancode == KEY_W:
		mu_key_label.self_modulate=mu_color
		if elements_dic[GameEnums.TaijiMode.mu]["count"]>0:
			EventBus.fire_event_3param("global_taiji_mode_changed",GameEnums.TaijiMode.mu,Global.taiji_mode,false)
	elif !event.pressed and event.scancode == KEY_W:
		mu_key_label.self_modulate=black_color
		
	if event.pressed and event.scancode == KEY_E:
		shui_key_label.self_modulate=shui_color
		if elements_dic[GameEnums.TaijiMode.shui]["count"]>0:
			EventBus.fire_event_3param("global_taiji_mode_changed",GameEnums.TaijiMode.shui,Global.taiji_mode,false)
	elif !event.pressed and event.scancode == KEY_E:
		shui_key_label.self_modulate=black_color
		
	if event.pressed and event.scancode == KEY_R:
		huo_key_label.self_modulate=huo_color
		if elements_dic[GameEnums.TaijiMode.huo]["count"]>0:
			EventBus.fire_event_3param("global_taiji_mode_changed",GameEnums.TaijiMode.huo,Global.taiji_mode,false)
	elif !event.pressed and event.scancode == KEY_R:
		huo_key_label.self_modulate=black_color

	if event.pressed and event.scancode == KEY_T:
		tu_key_label.self_modulate=tu_color
		if elements_dic[GameEnums.TaijiMode.tu]["count"]>0:
			EventBus.fire_event_3param("global_taiji_mode_changed",GameEnums.TaijiMode.tu,Global.taiji_mode,false)
	elif !event.pressed and event.scancode == KEY_T:
		tu_key_label.self_modulate=black_color

func _on_global_taiji_mode_changed(new_value,old_value,is_new_mode):
	if !is_new_mode:return
	match new_value:
		GameEnums.TaijiMode.jin:
			elements_dic[GameEnums.TaijiMode.jin]["count"]+=1
			elements_dic[GameEnums.TaijiMode.jin]["is_current_used"]=false
			#显示相关
			display_jin()
		GameEnums.TaijiMode.mu:
			elements_dic[GameEnums.TaijiMode.mu]["count"]+=1
			elements_dic[GameEnums.TaijiMode.mu]["is_current_used"]=false
			#显示相关
			display_mu()
		GameEnums.TaijiMode.shui:
			elements_dic[GameEnums.TaijiMode.shui]["count"]+=1
			elements_dic[GameEnums.TaijiMode.shui]["is_current_used"]=false
			#显示相关
			display_shui()
		GameEnums.TaijiMode.huo:
			elements_dic[GameEnums.TaijiMode.huo]["count"]+=1
			elements_dic[GameEnums.TaijiMode.huo]["is_current_used"]=false
			#显示相关
			display_huo()
		GameEnums.TaijiMode.tu:
			elements_dic[GameEnums.TaijiMode.tu]["count"]+=1
			elements_dic[GameEnums.TaijiMode.tu]["is_current_used"]=false
			#显示相关
			display_tu()
		_:
			elements_dic[GameEnums.TaijiMode.jin]["is_current_used"]=false
			elements_dic[GameEnums.TaijiMode.mu]["is_current_used"]=false
			elements_dic[GameEnums.TaijiMode.shui]["is_current_used"]=false
			elements_dic[GameEnums.TaijiMode.huo]["is_current_used"]=false
			elements_dic[GameEnums.TaijiMode.tu]["is_current_used"]=false
func _on_use_wuxing(player_taiji_mode):
	match player_taiji_mode:
		GameEnums.TaijiMode.jin:
			if elements_dic[GameEnums.TaijiMode.jin]["is_current_used"]:return
			if elements_dic[GameEnums.TaijiMode.jin]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.jin]["count"]-=1
			elements_dic[GameEnums.TaijiMode.jin]["is_current_used"]=true
			#显示相关
			display_jin()
		GameEnums.TaijiMode.mu:
			if elements_dic[GameEnums.TaijiMode.mu]["is_current_used"]:return
			if elements_dic[GameEnums.TaijiMode.mu]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.mu]["count"]-=1
			elements_dic[GameEnums.TaijiMode.mu]["is_current_used"]=true
			#显示相关
			display_mu()
		GameEnums.TaijiMode.shui:
			if elements_dic[GameEnums.TaijiMode.shui]["is_current_used"]:return
			if elements_dic[GameEnums.TaijiMode.shui]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.shui]["count"]-=1
			elements_dic[GameEnums.TaijiMode.shui]["is_current_used"]=true
			#显示相关
			display_shui()
		GameEnums.TaijiMode.huo:
			if elements_dic[GameEnums.TaijiMode.huo]["is_current_used"]:return
			if elements_dic[GameEnums.TaijiMode.huo]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.huo]["count"]-=1
			elements_dic[GameEnums.TaijiMode.huo]["is_current_used"]=true
			#显示相关
			display_huo()
		GameEnums.TaijiMode.tu:
			if elements_dic[GameEnums.TaijiMode.tu]["is_current_used"]:return
			if elements_dic[GameEnums.TaijiMode.tu]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.tu]["count"]-=1
			elements_dic[GameEnums.TaijiMode.tu]["is_current_used"]=true
			#显示相关
			display_tu()
			
func _on_mu_protect_close(value):
	if elements_dic[GameEnums.TaijiMode.mu]["count"]<1:return
	elements_dic[GameEnums.TaijiMode.mu]["count"]-=1
	elements_dic[GameEnums.TaijiMode.mu]["is_current_used"]=true
	#显示相关
	display_mu()

func _on_anti_counter(player_taiji_mode,anti_counter_score):
	match player_taiji_mode:
		GameEnums.TaijiMode.jin:
			if elements_dic[GameEnums.TaijiMode.jin]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.jin]["count"]-=1
			#显示相关
			display_jin()
		GameEnums.TaijiMode.mu:
			if elements_dic[GameEnums.TaijiMode.mu]["count"]<1:return
			#DebugUtils.log("GameEnums.TaijiMode.mu:count:"+str(elements_dic[GameEnums.TaijiMode.mu]["count"]))
			elements_dic[GameEnums.TaijiMode.mu]["count"]-=1
			#显示相关
			display_mu()
		GameEnums.TaijiMode.shui:
			if elements_dic[GameEnums.TaijiMode.shui]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.shui]["count"]-=1
			#显示相关
			display_shui()
		GameEnums.TaijiMode.huo:
			if elements_dic[GameEnums.TaijiMode.huo]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.huo]["count"]-=1
			#显示相关
			display_huo()
		GameEnums.TaijiMode.tu:
			if elements_dic[GameEnums.TaijiMode.tu]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.tu]["count"]-=1
			#显示相关
			display_tu()

func _on_wuxing_generation(lianpu_data):
	DebugUtils.log("_on_wuxing_generation:FiveElementsAccumulation")
	var player_taiji_mode=lianpu_data["player_mode"]
	match player_taiji_mode:
		GameEnums.TaijiMode.jin:
			if elements_dic[GameEnums.TaijiMode.jin]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.jin]["count"]-=1
			#显示相关
			display_jin()
		GameEnums.TaijiMode.mu:
			if elements_dic[GameEnums.TaijiMode.mu]["count"]<1:return
			#DebugUtils.log("GameEnums.TaijiMode.mu:count:"+str(elements_dic[GameEnums.TaijiMode.mu]["count"]))
			elements_dic[GameEnums.TaijiMode.mu]["count"]-=1
			#显示相关
			display_mu()
		GameEnums.TaijiMode.shui:
			if elements_dic[GameEnums.TaijiMode.shui]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.shui]["count"]-=1
			#显示相关
			display_shui()
		GameEnums.TaijiMode.huo:
			if elements_dic[GameEnums.TaijiMode.huo]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.huo]["count"]-=1
			#显示相关
			display_huo()
		GameEnums.TaijiMode.tu:
			if elements_dic[GameEnums.TaijiMode.tu]["count"]<1:return
			
			elements_dic[GameEnums.TaijiMode.tu]["count"]-=1
			#显示相关
			display_tu()
	EventBus.fire_event("wuxing_generation_available",lianpu_data)
func _on_anti_wuxing_generation(player_taiji_mode):
	match player_taiji_mode:
		GameEnums.TaijiMode.jin:
			elements_dic[GameEnums.TaijiMode.jin]["count"]+=1
			#elements_dic[GameEnums.TaijiMode.jin]["is_current_used"]=false
			#显示相关
			display_jin()
		GameEnums.TaijiMode.mu:
			elements_dic[GameEnums.TaijiMode.mu]["count"]+=1
			#elements_dic[GameEnums.TaijiMode.mu]["is_current_used"]=false
			#显示相关
			display_mu()
		GameEnums.TaijiMode.shui:
			elements_dic[GameEnums.TaijiMode.shui]["count"]+=1
			#elements_dic[GameEnums.TaijiMode.shui]["is_current_used"]=false
			#显示相关
			display_shui()
		GameEnums.TaijiMode.huo:
			elements_dic[GameEnums.TaijiMode.huo]["count"]+=1
			#elements_dic[GameEnums.TaijiMode.huo]["is_current_used"]=false
			#显示相关
			display_huo()
		GameEnums.TaijiMode.tu:
			elements_dic[GameEnums.TaijiMode.tu]["count"]+=1
			#elements_dic[GameEnums.TaijiMode.tu]["is_current_used"]=false
			#显示相关
			display_tu()

func display_jin():
	var count=elements_dic[GameEnums.TaijiMode.jin]["count"]
	if count<=0:
		jin_count_label.self_modulate=white_color
	else:
		jin_count_label.self_modulate=jin_color
	jin_count_label.text=str(count)
	jin_count_label.text=str(elements_dic[GameEnums.TaijiMode.jin]["count"])
	jin_count_label_tween.interpolate_property(jin_count_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	jin_count_label_tween.start()
func display_mu():
	var count=elements_dic[GameEnums.TaijiMode.mu]["count"]
	if count<=0:
		mu_count_label.self_modulate=white_color
	else:
		mu_count_label.self_modulate=mu_color
	mu_count_label.text=str(count)
	mu_count_label.text=str(elements_dic[GameEnums.TaijiMode.mu]["count"])
	mu_count_label_tween.interpolate_property(mu_count_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	mu_count_label_tween.start()
func display_shui():
	var count=elements_dic[GameEnums.TaijiMode.shui]["count"]
	if count<=0:
		shui_count_label.self_modulate=white_color
	else:
		shui_count_label.self_modulate=shui_color
	shui_count_label.text=str(count)
	shui_count_label.text=str(elements_dic[GameEnums.TaijiMode.shui]["count"])
	shui_count_label_tween.interpolate_property(shui_count_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	shui_count_label_tween.start()
func display_huo():
	var count=elements_dic[GameEnums.TaijiMode.huo]["count"]
	if count<=0:
		huo_count_label.self_modulate=white_color
	else:
		huo_count_label.self_modulate=huo_color
	huo_count_label.text=str(count)
	huo_count_label.text=str(elements_dic[GameEnums.TaijiMode.huo]["count"])
	huo_count_label_tween.interpolate_property(huo_count_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	huo_count_label_tween.start()
func display_tu():
	var count=elements_dic[GameEnums.TaijiMode.tu]["count"]
	if count<=0:
		tu_count_label.self_modulate=white_color
	else:
		tu_count_label.self_modulate=tu_color
	tu_count_label.text=str(count)
	tu_count_label_tween.interpolate_property(tu_count_label, "rect_scale",
	Vector2(3, 3), Vector2(2, 2), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tu_count_label_tween.start()

func _on_change_wuxing_calibration_rectscale(value):
	self.rect_scale=Vector2(value,value)
	DataMgr.set_setting("user","wuxing_calibration_rect_scale",value)
