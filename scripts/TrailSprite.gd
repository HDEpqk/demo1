extends Sprite



const FOLLOW_SPEED = 60
export var pointCount = 10
var is_long_pressed = false
var press_timer = 0.0
export var long_press_threshold = 0.01  # 推荐设置为0.5秒
var node2d = null
onready var trail=$Node/Trail

#处理连击
var combo_count := 0
var current_combo_type = null
var last_kill_time := 0.0
const COMBO_TIMEOUT := 1.0  # 连击有效时间窗口（秒）

func _ready():
	# 初始化节点引用
	node2d = $Area2D
	node2d.visible = false
	
	# 配置碰撞检测
	var area = $Area2D
	var collision = $Area2D/CollisionShape2D
	area.connect("body_entered", self, "_on_body_entered")
	area.connect("area_entered",self,"_on_area_entered")
	$Area2D/Sprite.texture=load("res://art/ui/game/Circle.png")
	trail.default_color=Color.black
   
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			press_timer = 0.0
			node2d.visible = false  # 按下瞬间隐藏
		else:
			is_long_pressed = false
			trail.clear_points()
			node2d.visible = false  # 松开时强制隐藏
			
			update_trailSprite_texture()
			

func _physics_process(delta):
	# 平滑跟随鼠标
	var target_pos = get_global_mouse_position()
	global_position = global_position.linear_interpolate(target_pos, delta * FOLLOW_SPEED)
	
	# 长按逻辑优化
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		press_timer += delta
		if press_timer >= long_press_threshold:
			is_long_pressed = true
			node2d.visible = true  # 长按成功时显示
			node2d.global_position = target_pos  # 保持与鼠标同步
	
	# 拖尾动态更新
	if is_long_pressed:
		trail.add_point(global_position)
		while trail.get_point_count() > pointCount:
			trail.remove_point(0)
	else:
		trail.clear_points()

func _on_body_entered(body):
	if !is_long_pressed: return
	
	if body.is_in_group("enemies"):
		# 获取敌人的太极模式类型
		var enemy_type = body.taiji_mode  # 需要确保敌人有taiji_mode属性
		
		# 连击逻辑
		var current_time = OS.get_ticks_msec() / 1000.0
		
		# 判断是否有效连击
		if current_combo_type == enemy_type && (current_time - last_kill_time) <= COMBO_TIMEOUT:
			combo_count += 1
			print("连击次数: ", combo_count)
		else:
			# 重置连击
			combo_count = 1
			current_combo_type = enemy_type
			print("新连击开始")
		
		# 更新最后消除时间
		last_kill_time = current_time
		
		# 处理连击奖励
		if combo_count >= 3:
			Global.set_taiji_mode(enemy_type)
			update_trailSprite_texture()
			combo_count = 0  # 重置连击
			print("触发太极模式转换: ", enemy_type)

		# 原有敌人处理逻辑
		match Global.taiji_mode:
			GameEnums.TaijiMode.yang:
				body.cycle_color()
			_:	
				body.queue_free()		
		node2d.visible = false

func _on_area_entered(area):
	if !is_long_pressed: return

	if area.is_in_group("center"):
		match Global.taiji_mode:
			GameEnums.TaijiMode.yang:
				Global.set_taiji_mode(GameEnums.TaijiMode.yin)
			_:	
				Global.set_taiji_mode(GameEnums.TaijiMode.yang)		
		update_trailSprite_texture()
		area.update_yinyang_image()

func update_trailSprite_texture():
	match Global.taiji_mode:
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
