extends Node2D

# 在脚本顶部预加载所有音效资源（只加载一次）
const SFX_JIN = preload("res://audio/sfx/jin1.wav")
const SFX_MU = preload("res://audio/sfx/mu1.wav")
const SFX_SHUI = preload("res://audio/sfx/shui1.wav")
const SFX_HUO = preload("res://audio/sfx/huo2.wav")
const SFX_TU = preload("res://audio/sfx/tu.mp3str")#之前是"res://audio/sfx/tu.tres"
const SFX_YANG= preload("res://audio/sfx/yang.mp3str")
const SFX_CYCLE_CENTER= preload("res://audio/sfx/cycle_center.wav")

const FOLLOW_SPEED = 60
export var pointCount = 10
var is_long_pressed = false
var press_timer = 0.0
export var long_press_threshold = 0.01  # 推荐设置为0.5秒
onready var area2d = $Area2D
onready var trail=$Node/Trail
onready var audio_player = $AudioStreamPlayer

#处理连击
var combo_count :int= 0
var current_combo_type = null
var first_kill_time:= 0.0
var last_kill_time := 0.0
const COMBO_TIMEOUT := 1  # 连击有效时间窗口（秒）
var combo_history = []  # 存储最近三次连击的太极模式
var combo_history_time = []  # 存储最近三次连击的太极模式对应的时间
const REQUIRED_UNIQUE_TYPES = 3  # 需要不同模式的数量



func _ready():
	# 配置碰撞检测
	var area = $Area2D
	var collision = $Area2D/CollisionShape2D
	area.connect("body_entered", self, "_on_body_entered")
	area.connect("area_entered",self,"_on_area_entered")
	trail.default_color=Color.black
	#订阅太极模式变化的事件
	EventBus.connect("global_taiji_mode_changed",self,"update_trailSprite_texture")
	#订阅太极模式变化的事件
	EventBus.connect("global_taiji_mode_changed",self,"play_taiji_mode_sound")
	#订阅player受伤的事件
	EventBus.connect("player_hurt",self,"_on_player_hurt")
	#订阅player恢复的事件
	EventBus.connect("player_recovery",self,"_on_player_recovery")
	#设置对象属于第1层
	area.collision_layer =1
	# 设置对象检测第2层和第3层和第4层
	area.collision_mask = (1 << 1) | (1 << 2) | (1 << 3)
	
func _input(event):
	if !(event is InputEventMouseButton):return
	if event.button_index == BUTTON_LEFT:
		if event.pressed:
			press_timer = 0.0
		else:
			is_long_pressed = false
			trail.clear_points()
		

#	elif event.button_index == BUTTON_RIGHT:
#		if event.pressed:
#			press_timer = 0.0
#			match Global.taiji_mode:
#				GameEnums.TaijiMode.yang:
#					EventBus.fire_event_3param("global_taiji_mode_changed",GameEnums.TaijiMode.yin,Global.taiji_mode,true)
#				_:	
#					EventBus.fire_event_3param("global_taiji_mode_changed",GameEnums.TaijiMode.yang,Global.taiji_mode,true)
#			audio_player.stream=SFX_CYCLE_CENTER
#			audio_player.play()
#			DebugUtils.log("播放了cycle_center音效")
#		else:
#			is_long_pressed = false
#			trail.clear_points()
		

func _physics_process(delta):
	# 平滑跟随鼠标
	var target_pos = get_global_mouse_position()
	global_position = global_position.linear_interpolate(target_pos, delta * FOLLOW_SPEED)
	
	# 长按逻辑优化
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		press_timer += delta
		if press_timer >= long_press_threshold:
			is_long_pressed = true
			#node2d.visible = true  # 长按成功时显示
			area2d.global_position = target_pos  # 保持与鼠标同步
#	elif Input.is_mouse_button_pressed(BUTTON_RIGHT) and Global.taiji_mode==GameEnums.TaijiMode.yang:
#		press_timer += delta
#		if press_timer >= long_press_threshold:
#			is_long_pressed = true
#			#node2d.visible = true  # 长按成功时显示
#			area2d.global_position = target_pos  # 保持与鼠标同步
	
	# 拖尾动态更新
	if is_long_pressed:
		trail.add_point(global_position)
		while trail.get_point_count() > pointCount:
			trail.remove_point(0)
	else:
		trail.clear_points()

func _on_body_entered(body):
	#DebugUtils.log("_on_body_entered:"+body.name)
	if !is_long_pressed or !Global.mode_status[Global.taiji_mode]["isActive"] : return
	
	if body.is_in_group("lianpu"):
		#关闭danger_area的检测
		if body.has_node("Area2D"):
			var area=body.get_node("Area2D")
			#DebugUtils.log("area:"+str(area))
			area.set_monitoring(false)
			area.set_monitorable(false)
			#DebugUtils.log("body Area2D is_monitoring:"+str(area.is_monitoring()))
			#DebugUtils.log("body Area2D is_monitorable:"+str(area.is_monitorable()))
			
		# 获取敌人的太极模式类型
		var enemy_type = body.taiji_mode  # 需要确保敌人有taiji_mode属性
		# 获取敌人的奖励分数
		var base_score=body.reward_score
	
	# 原有敌人处理逻辑
		match Global.taiji_mode:
			GameEnums.TaijiMode.yang:
				body.cycle_taiji_mode()
				if !body.is_in_group("lianpu_prop"):#如果不是lianpu_prop就播放切换声音
					audio_player.stream=SFX_YANG
					audio_player.play()
				return
			_:	
				if Global.taiji_mode==enemy_type:return#如果player和lianpu处于相同模式那么不产生交互
				if body.is_in_group("lianpu_prop"):
					if Global.is_invincible:
						body.handle_death()  # 销毁敌人
					else:
						#如果全局能量大于或小于脸谱能量，则执行消除逻辑
						if body.operation_type==GameEnums.OperationType.dayu and Global.energy<body.energy:return
						if body.operation_type==GameEnums.OperationType.xiaoyu and Global.energy>body.energy:return
						body.handle_death()  # 销毁敌人
				elif body.is_in_group("lianpu_water"):
					if Global.taiji_mode==GameEnums.TaijiMode.tu:
						body.handle_death_water(true)
						return
					if !Global.is_invincible:
						body.handle_death_water(false)
					else:
						body.handle_death_water(true)
				elif body.is_in_group("lianpu_hide"):
					if Global.is_invincible:
						body.handle_death()  # 销毁敌人
					elif Global.taiji_mode==GameEnums.TaijiMode.yin:
						return
					else:
						body.handle_death()  # 销毁敌人
				else:
					body.handle_death()  # 销毁敌人
		
		# 调用提炼后的连击更新方法
		update_combo(enemy_type, base_score)
						

func _on_area_entered(area):
	if !is_long_pressed: return

	if area.is_in_group("center"):
		match Global.taiji_mode:
			GameEnums.TaijiMode.yang:
				EventBus.fire_event_3param("global_taiji_mode_changed",GameEnums.TaijiMode.yin,Global.taiji_mode,true)
			_:	
				EventBus.fire_event_3param("global_taiji_mode_changed",GameEnums.TaijiMode.yang,Global.taiji_mode,true)
		audio_player.stream=SFX_CYCLE_CENTER
		audio_player.play()
		DebugUtils.log("播放了cycle_center音效")
	elif area.is_in_group("danger_area"):
		var root = area.get_parent()
		if root:
			# 获取克制关系
			var counter_target = Global.WUXING_COUNTER.get(Global.taiji_mode)
			print("counter_target:",counter_target)
			var root_mode=root.taiji_mode
			print("root_script_mode:",root_mode)
			if counter_target == root_mode:
				DebugUtils.log("五行相克！无视危险区域")
				# 如果危险区域被克制，视为击杀敌人并更新连击
				var enemy_type = root.taiji_mode
				var base_score = root.reward_score
				update_combo(enemy_type, base_score)
				root.handle_death()  #销毁敌人
				return
			elif Global.is_invincible:
				match Global.taiji_mode:
					GameEnums.TaijiMode.yang:
						root.cycle_taiji_mode()
						audio_player.stream=SFX_YANG
						audio_player.play()
						return
					_:	
						DebugUtils.log("crazy8时间！无视危险区域")
						# crazy8时间，视为击杀敌人并更新连击
						var enemy_type = root.taiji_mode
						var base_score = root.reward_score
						update_combo(enemy_type, base_score)
						root.handle_death()  #销毁敌人
						return
			elif Global.is_mu_protect_open:
				match Global.taiji_mode:
					GameEnums.TaijiMode.yang:
						DebugUtils.log("木保护！无视危险区域切换敌人")
						root.cycle_taiji_mode()
						audio_player.stream=SFX_YANG
						audio_player.play()
						EventBus.fire_event("mu_protect_close")
						return
					_:
						DebugUtils.log("木保护！无视危险区域销毁敌人")
						var enemy_type = root.taiji_mode
						var base_score = root.reward_score
						update_combo(enemy_type, base_score)
						root.handle_death()  #销毁敌人
						EventBus.fire_event("mu_protect_close")
						return
		else:
			print_debug("root not exist")
		EventBus.fire_event("player_hurt",Global.taiji_mode)
		DebugUtils.log("player hurt")

# 提炼的连击更新方法
func update_combo(enemy_type, base_score):
	# 连击逻辑
	var current_time = OS.get_ticks_msec() / 1000.0
	
	# 维护连击历史（最多保留最近三次）
	if combo_history.size() >= REQUIRED_UNIQUE_TYPES:
		combo_history.remove(0)
		combo_history_time.remove(0)
		if combo_history_time.size() >0:
			first_kill_time=combo_history_time[0]
	#记录第一次开始连击的时间
	if combo_history.size()<=0:
		first_kill_time=current_time
	combo_history.append(enemy_type)
	combo_history_time.append(current_time)
	
	# 检查时间有效性（所有连击都在时间窗口内）
	var valid_combo = true
	if combo_history.size() == REQUIRED_UNIQUE_TYPES:
		# 检查第一个和最后一个的时间差
		if (current_time - first_kill_time) > COMBO_TIMEOUT * (REQUIRED_UNIQUE_TYPES - 1):
			valid_combo = false
	
	# 判断是否满足特殊条件
	if valid_combo && combo_history.size() >= REQUIRED_UNIQUE_TYPES:
		# 使用字典去重后判断唯一性
		var unique_types = {}
		for type in combo_history:
			unique_types[type] = true
			
		if unique_types.size() == REQUIRED_UNIQUE_TYPES:
			EventBus.fire_event_3param("combo",3,COMBO_TIMEOUT,GameEnums.TaijiMode.tu)
			print("触发土之太极模式")
			EventBus.fire_event_3param("global_taiji_mode_changed", GameEnums.TaijiMode.tu,Global.taiji_mode,true)
			#提前记录倍数防止等待后倍数变了
			var multiple=Global.multiple
			yield(get_tree().create_timer(1.0), "timeout")
			var combo_score=base_score * 3*multiple
			var score_3x = Global.score + combo_score
			
			EventBus.fire_event("global_score_changed", score_3x)
			EventBus.fire_event_2param("combo_award",combo_score,3)
			# 重置连击状态
			reset_combo()
			last_kill_time = current_time  # 更新最后击杀时间
			return  # 直接返回不执行普通连击逻辑

	# 普通连击逻辑
	if current_combo_type == enemy_type && (current_time - last_kill_time) <= COMBO_TIMEOUT:
		combo_count += 1
		EventBus.fire_event_3param("combo",combo_count,COMBO_TIMEOUT,enemy_type)
		print("连击次数: ", combo_count)
	else:
		combo_count = 1
		current_combo_type = enemy_type
		EventBus.fire_event_3param("combo",combo_count,COMBO_TIMEOUT,enemy_type)
		print("新连击开始")

	# 处理奖励（每次连击更新时判断）
	if combo_count == 2:
		#提前记录倍数防止等待后倍数变了
		var multiple=Global.multiple
		yield(get_tree().create_timer(0.5), "timeout")
		DebugUtils.log("Global.score:"+str(Global.score))
		var combo_score=base_score * 2*multiple
		var score_2x = Global.score + combo_score
		EventBus.fire_event("global_score_changed", score_2x)
		EventBus.fire_event_2param("combo_award",combo_score,2)
	elif combo_count >= 3:
		#提前记录倍数防止等待后倍数变了
		var multiple=Global.multiple
		EventBus.fire_event_3param("global_taiji_mode_changed",enemy_type,Global.taiji_mode,true)
		yield(get_tree().create_timer(1.0), "timeout")
		var combo_score=base_score * 3*multiple
		var score_3x = Global.score + combo_score
		EventBus.fire_event("global_score_changed", score_3x)
		EventBus.fire_event_2param("combo_award",combo_score,3)
		# 重置连击状态
		reset_combo()

	last_kill_time = current_time
	
func reset_combo():
	# 重置连击状态
	combo_history.clear()
	combo_history_time.clear()
	combo_count = 0
	

func update_trailSprite_texture(new_value:int,old_value:int=0,is_new_mode:=true):
	match new_value:
		GameEnums.TaijiMode.yin:
			trail.default_color=Color.black
		GameEnums.TaijiMode.yang:
			trail.default_color=Color.white
		GameEnums.TaijiMode.jin:
			trail.default_color=Color.gold
		GameEnums.TaijiMode.mu:
			trail.default_color=Color.lawngreen
		GameEnums.TaijiMode.shui:
			trail.default_color=Color.skyblue
		GameEnums.TaijiMode.huo:
			trail.default_color=Color.firebrick
		GameEnums.TaijiMode.tu:
			trail.default_color=Color("#b36d41")
	if Global.mode_status[new_value]["isActive"]:
		trail.self_modulate.a=1
	else:
		trail.self_modulate.a=28/255.0



func play_taiji_mode_sound(new_value: int,old_value:int,is_new_mode:=true) -> void:
	var sound_stream = null
	
	match new_value:
		GameEnums.TaijiMode.yin:
			return  # 不播放音效，直接返回
			
		GameEnums.TaijiMode.yang:
			return  # 不播放音效，直接返回
			
		GameEnums.TaijiMode.jin:
			sound_stream = SFX_JIN
			DebugUtils.log("准备播放jin音效")
			
		GameEnums.TaijiMode.mu:
			sound_stream = SFX_MU
			DebugUtils.log("准备播放mu音效")
			
		GameEnums.TaijiMode.shui:
			sound_stream = SFX_SHUI
			DebugUtils.log("准备播放shui音效")
			
		GameEnums.TaijiMode.huo:
			sound_stream = SFX_HUO
			DebugUtils.log("准备播放huo音效")
			
		GameEnums.TaijiMode.tu:
			sound_stream = SFX_TU
			DebugUtils.log("准备播放tu音效")
			
		_:
			DebugUtils.log("未知的五行模式: " + str(new_value))
			return  # 未知模式，不播放任何音效
	
	# 统一处理音效播放
	if sound_stream:
		audio_player.stream = sound_stream
		audio_player.play()
		DebugUtils.log("音效播放成功")
	else:
		DebugUtils.log("错误: 未找到匹配的音效资源")

func _on_player_hurt(global_mode):
	DebugUtils.log("玩家受伤时做的事2")
	#调低trail透明度
	trail.self_modulate.a=28/255.0
	#禁用player和lianpu的交互

func _on_player_recovery(global_mode):
	#调回trail透明度
	trail.self_modulate.a=1
