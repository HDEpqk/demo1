extends Area2D

# 节点引用
onready var sprite = $Sprite
onready var collision_shape = $CollisionShape2D
onready var timers=$Timers

export var total_time: int = 5  # 总倒计时秒数
#export var sprite_alpha:float=28.0/255

onready var label_yin:Label=$Label_yin
onready var label_yang:Label=$Label_yang
onready var label_jin:Label=$Label_jin
onready var label_mu:Label=$Label_mu
onready var label_shui:Label=$Label_shui
onready var label_huo:Label=$Label_huo
onready var label_tu:Label=$Label_tu


onready var mode_timer={
	GameEnums.TaijiMode.yin:{"current_time":0,"total_time":0,"label":null},
	GameEnums.TaijiMode.yang:{"current_time":0,"total_time":0,"label":null},
	GameEnums.TaijiMode.jin:{"current_time":0,"total_time":0,"label":null},
	GameEnums.TaijiMode.mu:{"current_time":0,"total_time":0,"label":null},
	GameEnums.TaijiMode.shui:{"current_time":0,"total_time":0,"label":null},
	GameEnums.TaijiMode.huo:{"current_time":0,"total_time":0,"label":null},
	GameEnums.TaijiMode.tu:{"current_time":0,"total_time":0,"label":null}
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
	
	#初始化mode_timer字典
	for key in mode_timer.keys():
		mode_timer[key]["total_time"]=total_time
		match key:
			GameEnums.TaijiMode.yin:
				mode_timer[key]["label"]=label_yin
			GameEnums.TaijiMode.yang:
				mode_timer[key]["label"]=label_yang
			GameEnums.TaijiMode.jin:
				mode_timer[key]["label"]=label_jin
			GameEnums.TaijiMode.mu:
				mode_timer[key]["label"]=label_mu
			GameEnums.TaijiMode.shui:
				mode_timer[key]["label"]=label_shui
			GameEnums.TaijiMode.huo:
				mode_timer[key]["label"]=label_huo
			GameEnums.TaijiMode.tu:
				mode_timer[key]["label"]=label_tu
		if mode_timer[key]["label"]!=null:
			#隐藏文本
			var label:Label=mode_timer[key]["label"]
			label.visible=false


func _on_body_entered(body):
	DebugUtils.log("body entered")
	if body.is_in_group("lianpu"):
		if body.is_in_group("lianpu_dodge"):
			body.handle_death_water(true)
		else:
			body.handle_death()  # 销毁敌人
	
func _on_area_entered(area):
	if area.is_in_group("danger_area"):
		DebugUtils.log("center hurt")
		EventBus.fire_event("player_hurt",Global.taiji_mode)
		 #获取所有加入 "game_controller" 组的节点（通常只有根节点）
		var controller_nodes = get_tree().get_nodes_in_group("lianpu")
		if controller_nodes.size() > 0:
			var root_script = controller_nodes[0]
			if root_script!=null:
				root_script.handle_death()
				DebugUtils.log("center: root_script.handle_death()")
func play_hit_effect():
	# 添加视觉反馈
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1,0,0,1), 0.1)
	tween.tween_property(sprite, "modulate", Color(1,1,1,1), 0.3)

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
			$Timers/Timer_yin.start()
		GameEnums.TaijiMode.yang:
			$Timers/Timer_yang.start()
		GameEnums.TaijiMode.jin:
			$Timers/Timer_jin.start()			
		GameEnums.TaijiMode.mu:
			$Timers/Timer_mu.start()
		GameEnums.TaijiMode.shui:
			$Timers/Timer_shui.start()
		GameEnums.TaijiMode.huo:
			$Timers/Timer_huo.start()
		GameEnums.TaijiMode.tu:
			$Timers/Timer_tu.start()
	#设置当前时间
	mode_timer[mode]["current_time"]=mode_timer[mode]["total_time"]
	#把当前太极图片变得更透明
	sprite.self_modulate.a=28/255.0
	show_time_label(mode)
	#显示时间文本
	update_cooling_time_display(mode)

	
func _on_Timer_yin_timeout():
	mode_timer[GameEnums.TaijiMode.yin]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.yin)
	if mode_timer[GameEnums.TaijiMode.yin]["current_time"] <= 0:
		$Timers/Timer_yin.stop()
		sprite.self_modulate.a=1
		label_yin.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.yin)

func _on_Timer_yang_timeout():
	mode_timer[GameEnums.TaijiMode.yang]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.yang)
	if mode_timer[GameEnums.TaijiMode.yang]["current_time"] <= 0:
		$Timers/Timer_yang.stop()
		sprite.self_modulate.a=1
		label_yang.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.yang)
		

func _on_Timer_jin_timeout():
	mode_timer[GameEnums.TaijiMode.jin]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.jin)
	if mode_timer[GameEnums.TaijiMode.jin]["current_time"] <= 0:
		$Timers/Timer_jin.stop()
		sprite.self_modulate.a=1
		label_jin.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.jin)
		

func _on_Timer_mu_timeout():
	mode_timer[GameEnums.TaijiMode.mu]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.mu)
	if mode_timer[GameEnums.TaijiMode.mu]["current_time"] <= 0:
		$Timers/Timer_mu.stop()
		sprite.self_modulate.a=1
		label_mu.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.mu)
		

func _on_Timer_shui_timeout():
	mode_timer[GameEnums.TaijiMode.shui]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.shui)
	if mode_timer[GameEnums.TaijiMode.shui]["current_time"] <= 0:
		$Timers/Timer_shui.stop()
		sprite.self_modulate.a=1
		label_shui.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.shui)
		

func _on_Timer_huo_timeout():
	mode_timer[GameEnums.TaijiMode.huo]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.huo)
	if mode_timer[GameEnums.TaijiMode.huo]["current_time"] <= 0:
		$Timers/Timer_huo.stop()
		sprite.self_modulate.a=1
		label_huo.visible=false
		EventBus.fire_event("player_recovery",GameEnums.TaijiMode.huo)
		

func _on_Timer_tu_timeout():
	mode_timer[GameEnums.TaijiMode.tu]["current_time"] -= 1
	update_cooling_time_display(GameEnums.TaijiMode.tu)
	if mode_timer[GameEnums.TaijiMode.tu]["current_time"] <= 0:
		$Timers/Timer_tu.stop()
		sprite.self_modulate.a=1
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
