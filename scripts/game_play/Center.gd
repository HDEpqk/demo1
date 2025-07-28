extends Area2D

# 节点引用
onready var sprite = $Sprite
onready var collision_shape = $CollisionShape2D
onready var timers=$Timers
onready var mu_protect_vfx=$MuProtectVFX

export var total_time: int = 3  # 总倒计时秒数
#export var sprite_alpha:float=28.0/255

onready var timer_yin:Timer=$Timers/Timer_yin
onready var timer_yang:Timer=$Timers/Timer_yang
onready var timer_jin:Timer=$Timers/Timer_jin
onready var timer_mu:Timer=$Timers/Timer_mu
onready var timer_shui:Timer=$Timers/Timer_shui
onready var timer_huo:Timer=$Timers/Timer_huo
onready var timer_tu:Timer=$Timers/Timer_tu

onready var label_yin:Label=$Labels/Label_yin
onready var label_yang:Label=$Labels/Label_yang
onready var label_jin:Label=$Labels/Label_jin
onready var label_mu:Label=$Labels/Label_mu
onready var label_shui:Label=$Labels/Label_shui
onready var label_huo:Label=$Labels/Label_huo
onready var label_tu:Label=$Labels/Label_tu


onready var mode_timer={
	GameEnums.TaijiMode.yin:{"current_time":0,"total_time":0,"timer":null,"label":null},
	GameEnums.TaijiMode.yang:{"current_time":0,"total_time":0,"timer":null,"label":null},
	GameEnums.TaijiMode.jin:{"current_time":0,"total_time":0,"timer":null,"label":null},
	GameEnums.TaijiMode.mu:{"current_time":0,"total_time":0,"timer":null,"label":null},
	GameEnums.TaijiMode.shui:{"current_time":0,"total_time":0,"timer":null,"label":null},
	GameEnums.TaijiMode.huo:{"current_time":0,"total_time":0,"timer":null,"label":null},
	GameEnums.TaijiMode.tu:{"current_time":0,"total_time":0,"timer":null,"label":null}
}

func _ready():
	# 获取视口（屏幕）的尺寸
	var viewport_size = get_viewport().size
	# 将节点位置设置为屏幕中心
	position = viewport_size / 2
	# 连接信号
	connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")	
	update_yinyang_image(Global.taiji_mode)
	#订阅太极模式变化的事件
	EventBus.connect("global_taiji_mode_changed",self,"update_yinyang_image")
	#订阅player受伤的事件
	EventBus.connect("player_hurt",self,"_on_player_hurt")
	#订阅player恢复的事件
	EventBus.connect("player_recovery",self,"_on_center_recovery")
	#订阅木保护开启的事件
	EventBus.connect("mu_protect_open",self,"_on_mu_protect_open")
	#订阅木保护关闭的事件
	EventBus.connect("mu_protect_close",self,"_on_mu_protect_close")
	# 设置对象属于第4层
	collision_layer = (1 << 3)
	# 设置对象检测第1层和第2层和第3层 (第一层：player 第二层：lianpunormal和danger和hide 第三层：lianpuprop 第四层：center)
	collision_mask = 1 | (1 << 1) | (1 << 2)
	
	#初始化mode_timer字典
	for key in mode_timer.keys():
		mode_timer[key]["total_time"]=total_time
		match key:
			GameEnums.TaijiMode.yin:
				mode_timer[key]["timer"]=timer_yin
				mode_timer[key]["label"]=label_yin
			GameEnums.TaijiMode.yang:
				mode_timer[key]["timer"]=timer_yang				
				mode_timer[key]["label"]=label_yang
			GameEnums.TaijiMode.jin:
				mode_timer[key]["timer"]=timer_jin				
				mode_timer[key]["label"]=label_jin
			GameEnums.TaijiMode.mu:
				mode_timer[key]["timer"]=timer_mu				
				mode_timer[key]["label"]=label_mu
			GameEnums.TaijiMode.shui:
				mode_timer[key]["timer"]=timer_shui				
				mode_timer[key]["label"]=label_shui
			GameEnums.TaijiMode.huo:
				mode_timer[key]["timer"]=timer_huo				
				mode_timer[key]["label"]=label_huo
			GameEnums.TaijiMode.tu:
				mode_timer[key]["timer"]=timer_tu				
				mode_timer[key]["label"]=label_tu
		if mode_timer[key]["label"]!=null:
			#隐藏文本
			var label:Label=mode_timer[key]["label"]
			label.visible=false
		if mode_timer[key]["timer"]!=null:
			#暂停timer
			var timer:Timer=mode_timer[key]["timer"]
			timer.stop()
		EventBus.fire_event("player_recovery",key)
		sprite.self_modulate.a=1
	#隐藏MuProtectVFX
	mu_protect_vfx.visible=false

func _on_body_entered(body):
	DebugUtils.log("body entered")
	if body.is_in_group("lianpu"):
		if body.is_in_group("lianpu_water"):
			body.handle_death_water(true)
		elif body.is_in_group("lianpu_prop"):
			#当白颜色的脸谱穿过白色中心时不会被销毁,穿过其他中心时会被销毁
			if Global.taiji_mode==GameEnums.TaijiMode.yang:
				return
			else:
				body.handle_death()  # 销毁敌人
		elif body.is_in_group("lianpu_hide"):
			#当黑颜色的脸谱穿过黑色中心时不会被销毁,穿过其他中心时会被销毁
			if Global.taiji_mode==GameEnums.TaijiMode.yin:
				return
			else:
				body.handle_death()  # 销毁敌人
		else:
			body.handle_death()  # 销毁敌人
	
func _on_area_entered(area):
	if area.is_in_group("danger_area"):
		var root = area.get_parent()
		print("Root:",root)
		if root:
			# 获取克制关系
			var counter_target = Global.WUXING_COUNTER.get(Global.taiji_mode)
			print("counter_target:",counter_target)
			var root_mode=root.taiji_mode
			print("root_script_mode:",root_mode)
			if counter_target == root_mode:
				DebugUtils.log("center: root.handle_death()")
				root.handle_death()
				return
			elif Global.is_invincible:
				DebugUtils.log("crazy8时间！无视危险区域")
				# crazy8时间，视为击杀敌人
				root.handle_death()  #销毁敌人
				return
			elif Global.is_mu_protect_open:
				# 木保护作用，视为击杀敌人
				root.handle_death()  #销毁敌人
				EventBus.fire_event("mu_protect_close")
			else:
				DebugUtils.log("center hurt")
				EventBus.fire_event("player_hurt",Global.taiji_mode)
				DebugUtils.log("center: root_script.handle_death()")
				root.handle_death()
		else:
			print_debug("root not exist")


# 预加载所有纹理资源（只加载一次）
const TEXTURE_YIN = preload("res://art/ui/game/taiji_yin.png")
const TEXTURE_YANG = preload("res://art/ui/game/taiji_yang.png")
const TEXTURE_JIN = preload("res://art/ui/game/taiji_jin.png")
const TEXTURE_MU = preload("res://art/ui/game/taiji_mu.png")
const TEXTURE_SHUI = preload("res://art/ui/game/taiji_shui.png")
const TEXTURE_HUO = preload("res://art/ui/game/taiji_huo.png")
const TEXTURE_TU = preload("res://art/ui/game/taiji_tu.png")

func update_yinyang_image(new_value: int,old_value: int=0) -> void:
	var texture = get_texture_by_mode(new_value)
	
	if texture:
		sprite.texture = texture
		DebugUtils.log("已更新阴阳图像为: " + str(new_value))
	else:
		DebugUtils.log("错误: 未知的阴阳模式或纹理缺失 - " + str(new_value))
	
	if Global.mode_status[new_value]["isActive"]:
		sprite.self_modulate.a=1
	else:
		sprite.self_modulate.a=28/255.0
		show_time_label(new_value)
	#隐藏上一模式的时间文本
	hide_time_label(old_value)

func get_texture_by_mode(mode: int) -> Texture:
	match mode:
		GameEnums.TaijiMode.yin:
			return TEXTURE_YIN
		GameEnums.TaijiMode.yang:
			return TEXTURE_YANG
		GameEnums.TaijiMode.jin:
			return TEXTURE_JIN
		GameEnums.TaijiMode.mu:
			return TEXTURE_MU
		GameEnums.TaijiMode.shui:
			return TEXTURE_SHUI
		GameEnums.TaijiMode.huo:
			return TEXTURE_HUO
		GameEnums.TaijiMode.tu:
			return TEXTURE_TU
		_:
			return null

const SFX_HURT=preload("res://audio/sfx/hurt.wav")

func _on_player_hurt(mode):
	DebugUtils.log("玩家受伤时做的事")
	#播放受伤音效
	$AudioStreamPlayer.stream=SFX_HURT
	$AudioStreamPlayer.play()
	#把当前太极模式设置成冷却状态（开启计时器）
	match mode:
		GameEnums.TaijiMode.yin:
			timer_yin.start()
		GameEnums.TaijiMode.yang:
			timer_yang.start()
		GameEnums.TaijiMode.jin:
			timer_jin.start()			
		GameEnums.TaijiMode.mu:
			timer_mu.start()
		GameEnums.TaijiMode.shui:
			timer_shui.start()
		GameEnums.TaijiMode.huo:
			timer_huo.start()
		GameEnums.TaijiMode.tu:
			timer_tu.start()
	#设置当前时间
	mode_timer[mode]["current_time"]=mode_timer[mode]["total_time"]
	#把当前太极图片变得更透明
	sprite.self_modulate.a=28/255.0
	show_time_label(mode)
	#显示时间文本
	update_cooling_time_display(mode)

func _on_center_recovery(global_mode):
	sprite.self_modulate.a=1
	
func _on_Timer_yin_timeout():
	mode_timer[GameEnums.TaijiMode.yin]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.yin)
	if mode_timer[GameEnums.TaijiMode.yin]["current_time"] <= 0:
		timer_yin.stop()
		label_yin.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.yin)

func _on_Timer_yang_timeout():
	mode_timer[GameEnums.TaijiMode.yang]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.yang)
	if mode_timer[GameEnums.TaijiMode.yang]["current_time"] <= 0:
		timer_yang.stop()
		label_yang.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.yang)
		

func _on_Timer_jin_timeout():
	mode_timer[GameEnums.TaijiMode.jin]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.jin)
	if mode_timer[GameEnums.TaijiMode.jin]["current_time"] <= 0:
		timer_jin.stop()
		label_jin.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.jin)
		

func _on_Timer_mu_timeout():
	mode_timer[GameEnums.TaijiMode.mu]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.mu)
	if mode_timer[GameEnums.TaijiMode.mu]["current_time"] <= 0:
		timer_mu.stop()
		label_mu.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.mu)
		

func _on_Timer_shui_timeout():
	mode_timer[GameEnums.TaijiMode.shui]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.shui)
	if mode_timer[GameEnums.TaijiMode.shui]["current_time"] <= 0:
		timer_shui.stop()
		label_shui.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.shui)
		

func _on_Timer_huo_timeout():
	mode_timer[GameEnums.TaijiMode.huo]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.huo)
	if mode_timer[GameEnums.TaijiMode.huo]["current_time"] <= 0:
		timer_huo.stop()
		label_huo.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.huo)
		

func _on_Timer_tu_timeout():
	mode_timer[GameEnums.TaijiMode.tu]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.tu)
	if mode_timer[GameEnums.TaijiMode.tu]["current_time"] <= 0:
		timer_tu.stop()
		label_tu.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.tu)
		

# 更新显示
func update_cooling_time_display(mode:int):
	match mode:
		GameEnums.TaijiMode.yin:
			label_yin.text="%d" % mode_timer[mode]["current_time"]
		GameEnums.TaijiMode.yang:
			label_yang.text="%d" % mode_timer[mode]["current_time"]
		GameEnums.TaijiMode.jin:
			label_jin.text="%d" % mode_timer[mode]["current_time"]	
		GameEnums.TaijiMode.mu:
			label_mu.text="%d" % mode_timer[mode]["current_time"]
		GameEnums.TaijiMode.shui:
			label_shui.text="%d" % mode_timer[mode]["current_time"]
		GameEnums.TaijiMode.huo:
			label_huo.text="%d" % mode_timer[mode]["current_time"]
		GameEnums.TaijiMode.tu:
			label_tu.text="%d" % mode_timer[mode]["current_time"]

func show_time_label(mode:int):
	#根据模式开启时间文本
	match mode:
		GameEnums.TaijiMode.yin:
			label_yin.visible=true
		GameEnums.TaijiMode.yang:
			label_yang.visible=true
		GameEnums.TaijiMode.jin:
			label_jin.visible=true
		GameEnums.TaijiMode.mu:
			label_mu.visible=true
		GameEnums.TaijiMode.shui:
			label_shui.visible=true
		GameEnums.TaijiMode.huo:
			label_huo.visible=true
		GameEnums.TaijiMode.tu:
			label_tu.visible=true
func hide_time_label(mode:int):
	#根据模式隐藏时间文本
	match mode:
		GameEnums.TaijiMode.yin:
			label_yin.visible=false
		GameEnums.TaijiMode.yang:
			label_yang.visible=false
		GameEnums.TaijiMode.jin:
			label_jin.visible=false
		GameEnums.TaijiMode.mu:
			label_mu.visible=false
		GameEnums.TaijiMode.shui:
			label_shui.visible=false
		GameEnums.TaijiMode.huo:
			label_huo.visible=false
		GameEnums.TaijiMode.tu:
			label_tu.visible=false

func _on_mu_protect_open(value):
	DebugUtils.log("_on_mu_protect_open: Center")
	#显示MuProtectVFX
	mu_protect_vfx.visible=true
	#播放MuProtectVFX的动画
	var ap=mu_protect_vfx.get_node("AnimationPlayer") as AnimationPlayer
	if ap!=null:
		ap.play("born")
	else:
		DebugUtils.log("未找到mu_protect_vfx的AnimationPlayer")

func _on_mu_protect_close(value):
	DebugUtils.log("_on_mu_protect_close: Center")
	#隐藏MuProtectVFX
	mu_protect_vfx.visible=false
	#播放木保护关闭的音效
	DebugUtils.log("播放木保护关闭的音效")
func reset_center():
	pass
