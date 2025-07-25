extends "res://scripts/game_play/Lianpu.gd"

# 敌人寻路的相关变量
var is_avoiding_center = false
var exit_direction = Vector2.ZERO
var screen_margin = 50.0  # 屏幕边界外的销毁距离
var exit_speed=50
var exit_velocity = Vector2.ZERO

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
			start_avoid_center_behavior()

	if is_set_linear_velocity:
		# 应用当前速度
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
		
func _ready():
	._ready()
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	#设置对象属于第3层
	collision_layer =1<<2
	# 设置对象检测第1层和第4层
	collision_mask = 1 | (1<<3)
	#设置脸谱大小
	#set_scale(Vector2(2,2))
func cycle_taiji_mode():
	pass

func init(_mode:int, pos:Vector2, _reward_score:float, _speed:float):
	.init(_mode, pos, _reward_score, _speed)
	#初始能量值
	var	random = RandomNumberGenerator.new()
	random.randomize()
	energy=random.randi_range(0,10)
	DebugUtils.log("初始能量："+str(energy))
	update_energy_label()
	#开启碰撞体
	$BodyCollision.set("disabled", false)



