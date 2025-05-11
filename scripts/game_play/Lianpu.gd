#Lianpu.gd
extends RigidBody2D

#太极模式枚举
var taiji_mode: int  # 类型为GameEnums.TaijiMode 
export var speed = 30
var energy:float
var operation_type # 运算类型
# 存储所有死亡动画名称的数组
var death_animations = []
#消除的奖励分数
var reward_score:float

#寻路相关
var avoidance_distance = 80  # 检测障碍物的距离阈值
onready var target_position = get_viewport().size/2
var waypoint_distance = 200  # 路径点到中心的距离
var waypoint = Vector2.ZERO
var at_waypoint = false

func _physics_process(delta):
	if !at_waypoint:
		# 先移动到路径点
		var direction = (waypoint - global_position).normalized()
		linear_velocity = direction * speed
		
		if global_position.distance_to(waypoint) < 5:
			at_waypoint = true
	else:
		# 再移动到中心点
		var direction = (target_position - global_position).normalized()
		linear_velocity = direction * speed
	
# 定义太极模式循环顺序（与原颜色顺序对应）
var taiji_order = [
	GameEnums.TaijiMode.huo,  
	GameEnums.TaijiMode.jin, 
	GameEnums.TaijiMode.mu,  
	GameEnums.TaijiMode.shui
]

onready var sprite:Sprite = $Sprite

func _ready():
	#关闭AnimatedDeath
	$AnimatedDeath.visible=false
	# 初始化随机数种子
	randomize()
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	 # 为每个刚体生成随机路径点（围绕中心点）
	var angle = randf() * TAU
	waypoint = target_position + Vector2.RIGHT.rotated(angle) * waypoint_distance


func init(_mode:int, pos:Vector2,_reward_score:float,_speed:float):
	# 验证模式有效性
	if not taiji_order.has(_mode):
		printerr("无效的太极模式:", _mode)
		_mode = taiji_order[0]  # 默认火模式
	
	taiji_mode = _mode
	position = pos
	reward_score=_reward_score
	speed=_speed
	
	#var viewport_size = get_viewport().size
	# 移动逻辑保持不变
	#linear_velocity = (target_position - pos).normalized() * speed
	#初始化奖励分数



func cycle_taiji_mode():
	# 改为循环太极模式
	var current_index = taiji_order.find(taiji_mode)
	var next_index = (current_index + 1) % taiji_order.size()
	taiji_mode = taiji_order[next_index]



# 释放方法保持不变
func queue_free():
	sleeping = true
	.queue_free()

func handle_death():

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
	#打开AnimatedDeath
	$AnimatedDeath.visible=true
	#随机播放死亡动画
	if death_animations.size() > 0:
		# 随机选择一个死亡动画
		var random_index = randi() % death_animations.size()
		var random_animation:String = death_animations[random_index]

		#播放随机选择的动画
		$AnimationPlayer.play(random_animation)
	else:
		print("No death animations found.")

func _on_animation_finished():
	#DebugUtils.log("处理动画播放完成逻辑")
	call_deferred("queue_free")  # 延迟安全销毁




func calculate_avoidance() -> Vector2:
	var avoidance = Vector2.ZERO
	var space_state = get_world_2d().direct_space_state
	
	# 创建圆形检测区域
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = avoidance_distance
	
	# 正确设置shape属性（使用shape_rid）
	var query = Physics2DShapeQueryParameters.new()
	query.shape_rid = circle_shape.get_rid()  # 注意这里使用shape_rid
	query.transform = Transform2D(0, global_position)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	
	# 执行形状查询
	var results = space_state.intersect_shape(query)
	for result in results:
		var other = result.collider
		if other != self and is_instance_valid(other) and other is RigidBody2D:
			var direction = global_position - other.global_position
			var distance = direction.length()
			if distance > 0:  # 避免除零错误
				# 距离越近，排斥力越大
				avoidance += direction.normalized() * (1.0 - distance / avoidance_distance)
	
	return avoidance.normalized() if avoidance.length() > 0 else Vector2.RIGHT

