#Lianpu.gd
extends RigidBody2D

# 在脚本顶部预加载所有音效资源（只加载一次）
const SFX_HUO_COUNTER_JIN = preload("res://audio/sfx/huo_counter_jin.tres")
const SFX_JIN_COUNTER_MU=preload("res://audio/sfx/jin_counter_mu1.wav")
const SFX_TU_COUNTER_SHUI=preload("res://audio/sfx/tu_counter_shui.wav")
const SFX_SHUI_COUNTER_HUO=preload("res://audio/sfx/shui_counter_huo.tres")
const SFX_HURT=preload("res://audio/sfx/hurt.wav")
const SFX_HIT=preload("res://audio/sfx/hit2.wav")
const LAYER_DEAD = 4 # 定义一个死亡层

#太极模式枚举
var taiji_mode: int  # 类型为GameEnums.TaijiMode
var speed :float
var energy:float
var operation_type # 运算类型

var death_animations = []# 存储所有死亡动画名称的数组
var is_dying = false#当前是否正在死亡


var reward_score:float#消除的基础奖励分数
var lianpu_type:String

#寻路相关
onready var center_position = get_viewport().size/2
var waypoint_distance = 200  # 路径点到中心的距离
var waypoint = Vector2.ZERO
var at_waypoint = false
var at_center:bool=false
var is_set_linear_velocity=false
var is_avoiding_center = false
var exit_direction = Vector2.ZERO
var screen_margin = 50.0  # 屏幕边界外的销毁距离
var exit_velocity = Vector2.ZERO
var exit_speed:float

func start_avoid_center_behavior():
	if !is_avoiding_center:
		is_avoiding_center = true
		
		# 获取屏幕尺寸
		var viewport_size = get_viewport_rect().size
		
		# 计算到各屏幕边缘的距离
		var to_left = global_position.x
		var to_right = viewport_size.x - global_position.x
		var to_top = global_position.y
		var to_bottom = viewport_size.y - global_position.y
		
		# 找到最小距离（使用嵌套 min()）
		var min_dist = min(min(to_left, to_right), min(to_top, to_bottom))
		
		# 确定最小距离对应的方向
		if min_dist == to_left:
			exit_direction = Vector2(-1, 0)  # 向左
		elif min_dist == to_right:
			exit_direction = Vector2(1, 0)   # 向右
		elif min_dist == to_top:
			exit_direction = Vector2(0, -1)  # 向上
		else:  # min_dist == to_bottom
			exit_direction = Vector2(0, 1)   # 向下
		
		# 添加随机偏移使移动更自然
		var random_angle = rand_range(-PI/6, PI/6)  # ±30度随机偏移
		exit_direction = exit_direction.rotated(random_angle).normalized()
		
		# 设置离开速度
		exit_velocity = exit_direction * exit_speed
		is_set_linear_velocity = true
		is_avoiding_center=true
		DebugUtils.log("开始远离中心点移动")
		DebugUtils.log("离开移动方向: " + str(exit_direction))

func _physics_process(delta):
	if !at_waypoint:
		# 移动到路径点
		var direction = (waypoint - global_position).normalized()
		linear_velocity = direction * speed

		if global_position.distance_to(waypoint) < 5:
			at_waypoint = true
	elif !at_center:
		#再移动到中心点
		var direction = (center_position - global_position).normalized()
		linear_velocity = direction * speed
		if global_position.distance_to(center_position) < 5:
			at_center=true
			start_avoid_center_behavior()

	if is_set_linear_velocity:
		# 应用当前离开速度
		linear_velocity = exit_velocity
		is_set_linear_velocity=false
		DebugUtils.log("只设置一次linear_velocity")
	if is_avoiding_center:
		# 检查是否超出屏幕边界
		var viewport_rect = get_viewport_rect()
		viewport_rect = viewport_rect.grow(screen_margin)  # 扩大边界

		if !viewport_rect.has_point(global_position):
			# 超出屏幕后销毁
			queue_free()
	
# 定义太极模式循环顺序（与原颜色顺序对应）
var taiji_order = [
	GameEnums.TaijiMode.huo,  
	GameEnums.TaijiMode.jin, 
	GameEnums.TaijiMode.mu,  
	GameEnums.TaijiMode.shui
]

onready var sprite:Sprite = $Sprite

func _ready():
	 # 为每个刚体生成随机路径点（围绕中心点）
	var angle = randf() * TAU
	waypoint = center_position + Vector2.RIGHT.rotated(angle) * waypoint_distance
	#把刚体重力缩放设为0
	set_gravity_scale(0)
	if $AnimationPlayer!=null:
		#获取所有死亡动画的名称
		for anim in $AnimationPlayer.get_animation_list():
			if anim.begins_with("death_"):
				death_animations.append(anim)
	if $AnimatedDeath!=null:
		#关闭死亡动画sprite
		$AnimatedDeath.visible=false
	if $AnimatedSprite!=null:
		#开启普通动画
		$AnimatedSprite.visible=true
#	if $AudioStreamPlayer!=null:
#		$AudioStreamPlayer.set_volume_db(-10)

func init(dic:Dictionary):
	var _mode=dic["mode"]
	var pos=dic["pos"]
	var _reward_score=dic["reward_score"]
	var _speed=dic["speed"]
	var _lianpu_type=dic["lianpu_type"]
	# 验证模式有效性
	if not taiji_order.has(_mode):
		printerr("无效的太极模式:", _mode)
		_mode = taiji_order[0]  # 默认火模式
		

	lianpu_type=_lianpu_type
	taiji_mode = _mode
	DebugUtils.log("初始模式："+str(taiji_mode))
	global_position = pos
	reward_score=_reward_score
	speed=_speed
	exit_speed=speed*2
	print("exit_speed:",exit_speed)
	update_operation_type(_mode)
	DebugUtils.log("初始运算类型："+str(operation_type))
	#脸谱能量字体跟随太极模式颜色
	init_energy_label_color()
	#初始脸谱能量字体大小
	if $EnergyLabel!=null:
		$EnergyLabel.set_scale($EnergyLabel.get_scale()*1.5)
	#初始脸谱碰撞器大小
#	if $BodyCollision!=null:
#		#$BodyCollision.set_scale($BodyCollision.get_scale()*2)
#		pass
#	if $Sprite!=null:
#		#$Sprite.set_scale($Sprite.get_scale()*2)
#		pass
#	if $AnimatedSprite!=null:
#		#$AnimatedSprite.set_scale($AnimatedSprite.get_scale()*2)
#		pass
#	if $AnimatedDeath!=null:
#		#$AnimatedDeath.set_scale($AnimatedDeath.get_scale()*2)
#		pass



func cycle_taiji_mode():
	# 自动获取类型名称（如"danger_fire"）
	var type_name = self.filename.get_file().trim_suffix(".tscn").to_lower()
	DebugUtils.log(" 自动获取类型名称:"+type_name)
	EventBus.fire_event("cycle_lianpu", {
		"current_type": type_name,
		"position": global_position,
		"origin_node": self  # 直接传递节点引用
	})


# 释放方法保持不变
func queue_free():
	sleeping = true
	.queue_free()

func handle_death():
	if is_dying:return#如果正在死亡则退出避免重复调用
	
	is_dying=true
	# 切换到死亡层（Player 不检测此层）
	if has_node("Area2D"):
		$Area2D.set_collision_layer(1 << LAYER_DEAD)  # 设置层
		$Area2D.set_collision_mask(0)  # 设置掩码，不检测任何层
	#根据taiji_mode改变死亡动画的颜色
	match taiji_mode:
		GameEnums.TaijiMode.yin:
			$AnimatedDeath.self_modulate=Color.black
		GameEnums.TaijiMode.yang:
			$AnimatedDeath.self_modulate=Color.white
		GameEnums.TaijiMode.huo:
			$AnimatedDeath.self_modulate=Color("#e40000")
		GameEnums.TaijiMode.jin:
			$AnimatedDeath.self_modulate=Color("#e6da29")
		GameEnums.TaijiMode.mu:
			$AnimatedDeath.self_modulate=Color("#28c641")
		GameEnums.TaijiMode.shui:
			$AnimatedDeath.self_modulate=Color("#2d93dd")
		GameEnums.TaijiMode.tu:
			$AnimatedDeath.self_modulate=Color("#b36d41")
		
	$AnimatedDeath.visible=true#打开AnimatedDeath
	if $EnergyLabel!=null:
		$EnergyLabel.visible=false#关闭EnergyLabel
	#随机播放死亡动画
	if death_animations.size() > 0:
		# 随机选择一个死亡动画
		var random_index = randi() % death_animations.size()
		var random_animation:String = death_animations[random_index]

		#播放随机选择的动画
		$AnimationPlayer.play(random_animation)
	else:
		print("No death animations found.")
	
	
	handle_element_counter_sfx()#播放死亡音效
	handle_score_operation()#加分
	handle_energy_operation()#根据运算类型进行不同运算
	
	
func handle_score_operation():
	handle_element_generation(Global.taiji_mode,taiji_mode,reward_score)#处理五行相生
	#处理克制加分与被克制减分相关逻辑
	var result=handle_element_counter(Global.taiji_mode,taiji_mode,reward_score)
	match result:
		0:
			var lianpu_score=reward_score*Global.multiple
			var new_score=Global.score+lianpu_score
			EventBus.fire_event("kill_lianpu_award",lianpu_score)
			#yield(get_tree().create_timer(1.0), "timeout")
			EventBus.fire_event("global_score_changed",new_score)
	

func handle_energy_operation():
	#根据运算类型进行不同运算
	var new_energy_value=0
	match operation_type:
		GameEnums.OperationType.jia:
			new_energy_value=Global.energy+energy
		GameEnums.OperationType.jian:
			new_energy_value=Global.energy-energy
		GameEnums.OperationType.cheng:
			new_energy_value=Global.energy*energy
		GameEnums.OperationType.chu:
			if energy==0:
				if Global.is_invincible:return
				if Global.is_mu_protect_open:
					EventBus.fire_event("mu_protect_close")
					return
				#触发游戏结束事件
				EventBus.fire_event("game_over","你÷了0┗|｀O′|┛ 嗷~~!")
			else:
				new_energy_value=Global.energy/energy
	#如果不处于无敌模式则进行能量计算
	if !Global.is_invincible:
		EventBus.fire_event("global_energy_changed",new_energy_value)
		

#在敌人处理逻辑中添加分数调整
func handle_element_counter(global_mode, lianpu_mode, base_score):
	# 获取克制关系
	var counter_target = Global.WUXING_COUNTER.get(global_mode)
	
	if counter_target == lianpu_mode:
		# 克制加成
		var bonus_score = base_score * 2
		var counter_score=bonus_score*Global.multiple
		print("五行相克！加成分数: ", counter_score)
		var new_score=Global.score+counter_score
		EventBus.fire_event_2param("counter",global_mode,counter_score)
		#yield(get_tree().create_timer(1.0), "timeout")
		EventBus.fire_event("global_score_changed",new_score)
		Engine.time_scale=0.01
		yield(get_tree().create_timer(0.001), "timeout")
		Engine.time_scale=1
		return 1
	elif Global.WUXING_COUNTER.get(lianpu_mode) == global_mode:
		if Global.is_invincible:
			DebugUtils.log("无敌时间！无视克制关系销毁敌人")
			return 0
		if Global.is_mu_protect_open:
			DebugUtils.log("木保护！无视克制关系销毁敌人")
			EventBus.fire_event("mu_protect_close")
			return 0
		# 被克制惩罚
		var penalty = base_score * 2
		EventBus.fire_event("player_hurt",Global.taiji_mode)
		var anti_counter_score=penalty
		print("反被克制！扣除分数: ", anti_counter_score)
		var new_score=max(0,Global.score-anti_counter_score)#确保值不为负数
		if new_score==0:
			penalty=0
		EventBus.fire_event_2param("anti_counter",global_mode,penalty)
		#yield(get_tree().create_timer(1.0), "timeout")
		EventBus.fire_event("global_score_changed",new_score)
		return 1
	else:
		# 普通得分
		return 0

func handle_element_generation(global_mode,lianpu_mode,base_score):
		# 获取相生关系
	var generation_target = Global.WUXING_GENERATION.get(global_mode)
	
	#global_position-=Vector2(100,0)
	if generation_target == lianpu_mode:
		DebugUtils.log("玩家生脸谱")
		EventBus.fire_event("wuxing_generation",{
		"position": global_position,
		"lianpu_type":lianpu_type,
		"player_mode":global_mode
	})
		return
	if Global.WUXING_GENERATION.get(lianpu_mode) == global_mode:
		DebugUtils.log("玩家被脸谱生")
		EventBus.fire_event("anti_wuxing_generation",global_mode)
		return
	EventBus.fire_event("use_wuxing",Global.taiji_mode)
#根据太极模式初始化脸谱能量字体
func init_energy_label_color():
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			$EnergyLabel.self_modulate=Color("#e40000")
		GameEnums.TaijiMode.jin:
			$EnergyLabel.self_modulate=Color("#e6da29")
		GameEnums.TaijiMode.mu:
			$EnergyLabel.self_modulate=Color("#28c641")
		GameEnums.TaijiMode.shui:
			$EnergyLabel.self_modulate=Color("#2d93dd")
			
func _on_death_animation_finished():
	DebugUtils.log("死亡动画结束的回调")
	queue_free()


func handle_element_counter_sfx():
	# 获取克制关系
	var counter_target = Global.WUXING_COUNTER.get(Global.taiji_mode)
	var sound_stream = null
	if counter_target == taiji_mode:
		match counter_target:
			GameEnums.TaijiMode.jin:
				DebugUtils.log("播放了kejin音效")
				sound_stream=SFX_HUO_COUNTER_JIN
			GameEnums.TaijiMode.mu:
				sound_stream=SFX_JIN_COUNTER_MU
				DebugUtils.log("播放了kemu音效")	
			GameEnums.TaijiMode.shui:
				sound_stream=SFX_TU_COUNTER_SHUI
				DebugUtils.log("播放了keshui音效")
			GameEnums.TaijiMode.huo:
				sound_stream=SFX_SHUI_COUNTER_HUO
				DebugUtils.log("播放了kehuo音效")
		
	elif Global.WUXING_COUNTER.get(taiji_mode) == Global.taiji_mode:
		if Global.is_invincible:
			#如果当前处于疯狂时间或者有木保护就不播放受伤音效
			sound_stream=SFX_HIT
		elif Global.is_mu_protect_open:
			sound_stream=SFX_HIT
		else:
			sound_stream=SFX_HURT
	else:
		sound_stream=SFX_HIT

	$AudioStreamPlayer.stream=sound_stream
	$AudioStreamPlayer.play()

func update_operation_type(mode:int):
	# 根据太极模式设置运算类型
	match mode:
		GameEnums.TaijiMode.huo:
			operation_type=GameEnums.OperationType.jia  # 火对应加
		GameEnums.TaijiMode.jin:
			operation_type=GameEnums.OperationType.jian # 金对应减
		GameEnums.TaijiMode.mu:
			operation_type=GameEnums.OperationType.cheng # 木对应乘
		GameEnums.TaijiMode.shui:
			operation_type=GameEnums.OperationType.chu   # 水对应除
func update_energy_label():
	match operation_type:
		GameEnums.OperationType.jia:
			$EnergyLabel.text="+"+str(energy)
		GameEnums.OperationType.jian:
			$EnergyLabel.text="-"+str(energy)
		GameEnums.OperationType.cheng:
			$EnergyLabel.text="×"+str(energy)
		GameEnums.OperationType.chu:
			$EnergyLabel.text="÷"+str(energy)


