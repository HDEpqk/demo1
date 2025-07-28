extends "res://scripts/game_play/Lianpu.gd"

# 敌人寻路的相关变量
var is_avoiding_center = false
var exit_direction = Vector2.ZERO
var screen_margin = 50.0  # 屏幕边界外的销毁距离
var exit_speed=50
var exit_velocity = Vector2.ZERO
var at_center:bool=false

#hide相关
var hide_timer:Timer
var hide_time:float=5
var is_hiding:bool=false
var tween:Tween

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
	if !at_center:
		# 再移动到中心点
		var direction = (target_position - global_position).normalized()
		linear_velocity = direction * speed
		if global_position.distance_to(target_position) < 5:
			at_center=true
			start_avoid_center_behavior()
			#linear_velocity=Vector2( 0, 0 )

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
		
func _ready():
	._ready()
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	#设置对象属于第2层
	collision_layer =1<<1
	# 设置对象检测第1层和第4层
	collision_mask = 1 | (1<<3)
	#初始化hide_timer
	hide_timer=get_node("HideTimer")
	if hide_timer!=null:
		hide_timer.set_wait_time(hide_time)
		hide_timer.connect("timeout",self,"_on_hidetimer_timeout")
		hide_timer.start()
	else:
		push_warning("未找到hide_timer")
	#初始化tween
	tween = get_node("Tween")
	if tween==null:
		push_warning("未找到tween")


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
	$Sprite.visible=true

func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set("disabled", true)
	$Sprite.visible=false
	.handle_death()

func _on_hidetimer_timeout():
	handle_hide()

func handle_hide():
	if !is_hiding:
		fade_out(self)
		is_hiding=true
	else:
		fade_in(self)
		is_hiding=false
# 淡入效果（显示）
func fade_in(object: CanvasItem, duration: float = 0.5):
	if tween==null: return
	object.show()  # 确保对象可见
	tween.interpolate_property(object, "modulate:a",
		object.modulate.a,  # 当前透明度
		1.0,               # 目标透明度（完全不透明）
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()
	yield(tween, "tween_completed")

# 淡出效果（隐藏）
func fade_out(object: CanvasItem, duration: float = 0.5):
	if tween==null: return
	tween.interpolate_property(object, "modulate:a",
		object.modulate.a,  # 当前透明度
		0.0,               # 目标透明度（完全透明）
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()
	yield(tween, "tween_completed")
	object.hide()  # 动画完成后隐藏
