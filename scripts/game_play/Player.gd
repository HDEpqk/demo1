extends Node2D



const FOLLOW_SPEED = 60
export var pointCount = 10
var is_long_pressed = false
var press_timer = 0.0
export var long_press_threshold = 0.01  # 推荐设置为0.5秒
onready var area2d = $Area2D
onready var trail=$Node/Trail

#处理连击
var combo_count := 0
var current_combo_type = null
var last_kill_time := 0.0
const COMBO_TIMEOUT := 1.0  # 连击有效时间窗口（秒）
var combo_history = []  # 存储最近三次连击的太极模式
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
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			press_timer = 0.0
			#node2d.visible = false  # 按下瞬间隐藏
		else:
			is_long_pressed = false
			trail.clear_points()
			#node2d.visible = false  # 松开时强制隐藏
			
			update_trailSprite_texture(Global.taiji_mode)
			

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
	
	# 拖尾动态更新
	if is_long_pressed:
		trail.add_point(global_position)
		while trail.get_point_count() > pointCount:
			trail.remove_point(0)
	else:
		trail.clear_points()

func _on_body_entered(body):
	if !is_long_pressed: return
	
	if body.is_in_group("lianpu"):
		# 获取敌人的太极模式类型
		var enemy_type = body.taiji_mode  # 需要确保敌人有taiji_mode属性
		# 获取敌人的奖励分数
		var base_score=body.reward_score
		
		 # 应用五行相克规则
		var actual_score = handle_element_counter(
			Global.taiji_mode,
			enemy_type,
			base_score
		)
		 # 显示克制关系提示
		if actual_score > base_score:
			show_counter_effect("相克加成")
		elif actual_score < base_score:
			show_counter_effect("反被克制") 
	
	# 原有敌人处理逻辑
		match Global.taiji_mode:
			GameEnums.TaijiMode.yang:
				body.cycle_taiji_mode()
				return
			_:	
				var new_score=Global.score+actual_score
				DebugUtils.log("new_score:"+str(new_score))
				EventBus.fire_event("global_score_changed",new_score)
				body.handle_death()
				
		# 连击逻辑
		var current_time = OS.get_ticks_msec() / 1000.0
		
 # 维护连击历史（最多保留最近三次）
		if combo_history.size() >= REQUIRED_UNIQUE_TYPES:
			combo_history.remove(0)
		combo_history.append(enemy_type)
		
		# 检查时间有效性（所有连击都在时间窗口内）
		var valid_combo = true
		if combo_history.size() == REQUIRED_UNIQUE_TYPES:
			# 检查第一个和最后一个的时间差
			if (current_time - last_kill_time) > COMBO_TIMEOUT * (REQUIRED_UNIQUE_TYPES - 1):
				valid_combo = false
		
		# 判断是否满足特殊条件
		if valid_combo && combo_history.size() >= REQUIRED_UNIQUE_TYPES:
			# 使用集合去重后判断唯一性
			var unique_types = {}
			for type in combo_history:
				unique_types[type] = true
				
			if unique_types.size() == REQUIRED_UNIQUE_TYPES:
				print("触发土之太极模式")
				EventBus.fire_event("global_taiji_mode_changed", GameEnums.TaijiMode.tu)
				var score_3x = Global.score + actual_score * 3
				EventBus.fire_event("global_score_changed", score_3x)
				# 重置连击状态
				combo_history.clear()
				combo_count = 0
				return  # 直接返回不执行普通连击逻辑

		# 保留原有普通连击逻辑（根据需要调整）
		
		if current_combo_type == enemy_type && (current_time - last_kill_time) <= COMBO_TIMEOUT:
			combo_count += 1
			print("连击次数: ", combo_count)
		else:
			combo_count = 1
			current_combo_type = enemy_type
			print("新连击开始")



		# 处理奖励（每次连击更新时判断）
		if combo_count == 2:
			DebugUtils.log("Global.score:"+str(Global.score))
			var score_2x = Global.score + actual_score * 2
			EventBus.fire_event("global_score_changed", score_2x)
		elif combo_count >= 3:
			var score_3x = Global.score + actual_score * combo_count
			EventBus.fire_event("global_score_changed", score_3x)
			EventBus.fire_event("global_taiji_mode_changed", enemy_type)
			combo_count = 0  # 重置连击


		last_kill_time = current_time
			
		#node2d.visible = false					

# 视觉反馈方法
func show_counter_effect(text):
	var label = Label.new()
	label.text = text
	label.add_color_override("font_color", Color.red if "克制" in text else Color.blue)
	add_child(label)
	label.rect_position = get_global_mouse_position()
	# 添加动画效果...

# 在敌人处理逻辑中添加分数调整
func handle_element_counter(global_mode, enemy_mode, base_score):
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
		return -penalty
	else:
		# 普通得分
		return base_score

func _on_area_entered(area):
	if !is_long_pressed: return

	if area.is_in_group("center"):
		match Global.taiji_mode:
			GameEnums.TaijiMode.yang:
				EventBus.fire_event("global_taiji_mode_changed",GameEnums.TaijiMode.yin)
			_:	
				EventBus.fire_event("global_taiji_mode_changed",GameEnums.TaijiMode.yang)
	elif area.is_in_group("danger_area"):
		DebugUtils.log("player hurt")
	
func update_trailSprite_texture(new_value:int):
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
	#DebugUtils.log("trail图片已更新")
