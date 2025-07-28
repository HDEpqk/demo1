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
#var actual_score:float=reward_score#消除的最终奖励分数，默认等于基础奖励分数

#寻路相关
onready var target_position = get_viewport().size/2
var waypoint_distance = 200  # 路径点到中心的距离
var waypoint = Vector2.ZERO
var at_waypoint = false
var is_set_linear_velocity=false


func _physics_process(delta):
	if !at_waypoint:
		# 先移动到路径点
		var direction = (waypoint - global_position).normalized()
		linear_velocity = direction * speed
		
		if global_position.distance_to(waypoint) < 5:
			at_waypoint = true
			is_set_linear_velocity=true
	if is_set_linear_velocity:
		# 再移动到中心点
		var direction = (target_position - global_position).normalized()
		linear_velocity = direction * speed
		is_set_linear_velocity=false
		DebugUtils.log("只设置一次linear_velocity")
	
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
	waypoint = target_position + Vector2.RIGHT.rotated(angle) * waypoint_distance
	#把刚体重力缩放设为0
	set_gravity_scale(0)

func init(_mode:int, pos:Vector2,_reward_score:float,_speed:float):
	# 验证模式有效性
	if not taiji_order.has(_mode):
		printerr("无效的太极模式:", _mode)
		_mode = taiji_order[0]  # 默认火模式
		
	#关闭死亡动画sprite
	$AnimatedDeath.visible=false
	#开启普通动画
	$AnimatedSprite.visible=true
	taiji_mode = _mode
	DebugUtils.log("初始模式："+str(taiji_mode))
	position = pos
	reward_score=_reward_score
	speed=_speed
	update_operation_type(_mode)
	DebugUtils.log("初始运算类型："+str(operation_type))
	#脸谱能量字体跟随太极模式颜色
	init_energy_label_color()
	#初始脸谱能量字体大小
	$EnergyLabel.set_scale(Vector2( 1.5, 1.5 ))



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
		GameEnums.TaijiMode.huo:
			$AnimatedDeath.self_modulate=Color("#e40000")
		GameEnums.TaijiMode.jin:
			$AnimatedDeath.self_modulate=Color("#e6da29")
		GameEnums.TaijiMode.mu:
			$AnimatedDeath.self_modulate=Color("#28c641")
		GameEnums.TaijiMode.shui:
			$AnimatedDeath.self_modulate=Color("#2d93dd") 
	
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
	#处理加分相关逻辑
	var actual_score=handle_element_counter_score(Global.taiji_mode,taiji_mode,reward_score)
	DebugUtils.log("当前的actual_score="+str(actual_score))
	var new_score=Global.score+actual_score*Global.multiple
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
				if Global.is_mu_protect_open:
					EventBus.fire_event("mu_protect_close")
					return
				DebugUtils.log("你÷了0所以game over!")
				#跳转到结束界面
				SceneMgr.change_scene("res://scene/game_scene/end/GameOverScene.tscn")
			else:
				new_energy_value=Global.energy/energy
	#如果不处于无敌模式则进行能量计算
	if !Global.is_invincible:
		EventBus.fire_event("global_energy_changed",new_energy_value)
		

#在敌人处理逻辑中添加分数调整
func handle_element_counter_score(global_mode, enemy_mode, base_score):
	# 获取克制关系
	var counter_target = Global.WUXING_COUNTER.get(global_mode)
	
	if counter_target == enemy_mode:
		# 克制加成
		var bonus_score = base_score * 2
		print("五行相克！加成分数: ", bonus_score)
		return bonus_score
	elif Global.WUXING_COUNTER.get(enemy_mode) == global_mode:
		# 被克制惩罚
		var penalty = base_score / 2
		print("反被克制！扣除分数: ", penalty)
		EventBus.fire_event("player_hurt",Global.taiji_mode)
		DebugUtils.log("反被克制！player hurt")
		return -penalty
	else:
		# 普通得分
		return base_score
	
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
		print("播放相克音效！: ")
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
		sound_stream=SFX_HURT
	else:
		DebugUtils.log("播放普通音效")
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
