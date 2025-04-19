extends Sprite

const FOLLOW_SPEED = 60
export var pointCount = 10
var is_long_pressed = false
var press_timer = 0.0
export var long_press_threshold = 0  # 推荐设置为0.5秒
var node2d = null
var is_yang_mode := false #阴阳状态

func _ready():
	# 初始化节点引用
	node2d = $Area2D
	node2d.visible = false
	
	# 配置碰撞检测
	var area = $Area2D
	var collision = $Area2D/CollisionShape2D
	area.connect("body_entered", self, "_on_body_entered")
	area.connect("area_entered",self,"_on_area_entered")
	$Area2D/Sprite.texture=load("res://art/BlackCircle.png")
	$Node/Trail.default_color=Color.black
   
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			press_timer = 0.0
			node2d.visible = false  # 按下瞬间隐藏
		else:
			is_long_pressed = false
			$Node/Trail.clear_points()
			node2d.visible = false  # 松开时强制隐藏
			
			update_trailSprite_texture(is_yang_mode)
			

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
		$Node/Trail.add_point(global_position)
		while $Node/Trail.get_point_count() > pointCount:
			$Node/Trail.remove_point(0)
	else:
		$Node/Trail.clear_points()

func _on_body_entered(body):
	if !is_long_pressed: return
	print("Collision with: ", body.name)
	# 实际游戏中的处理示例：
	if body.is_in_group("enemies"):
		if is_yang_mode:
			body.cycle_color()
		else:
			body.queue_free()
		node2d.visible = false  # 碰撞后隐藏

func _on_area_entered(area):
	if !is_long_pressed: 
		return
	print("Collision with: ", area.name)
	
	if area.is_in_group("center"):
		print("碰撞了center")
		is_yang_mode = !is_yang_mode
		update_trailSprite_texture(is_yang_mode)
		area.update_yinyang_image(is_yang_mode)

func update_trailSprite_texture(var is_yang_mode:bool):
	#更新鼠标滑动的图片
	if is_yang_mode:
		$Area2D/Sprite.texture=load("res://art/whiteCircle.png")
		$Node/Trail.default_color=Color.white
	else:
		$Area2D/Sprite.texture=load("res://art/BlackCircle.png")
		$Node/Trail.default_color=Color.black
