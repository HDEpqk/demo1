extends Node2D  # 改为Node2D以支持绘图

var is_yang_mode := false
var drag_start_pos := Vector2.ZERO
var drag_points := []
onready var ui = get_node("/root/Main/UI")

func _input(event):
	# 鼠标按下
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			drag_start_pos = event.position
			drag_points.clear()
		else:
			handle_drag_operation()
			is_yang_mode = !is_yang_mode  # 切换模式
			ui.update_mode(is_yang_mode)
			drag_points.clear()
			update()  # 清空轨迹
	
	# 鼠标移动
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_LEFT):
		drag_points.append(event.position)
		update()  # 触发重绘

func _draw():
	if drag_points.size() > 0:
		# 根据模式选择颜色
		var line_color = Color.white if is_yang_mode else Color.black
		# 绘制轨迹线
		draw_polyline(
			PoolVector2Array([drag_start_pos] + drag_points),
			line_color,
			2.0,
			true
		)

func handle_drag_operation():
	var space = get_world_2d().direct_space_state
	var params = Physics2DShapeQueryParameters.new()
	
	# 创建检测形状
	var line_shape = ConvexPolygonShape2D.new()
	line_shape.points = _get_simplified_points()
	
	params.set_shape(line_shape)
	params.collision_layer = 1
	
	for result in space.intersect_shape(params):
		var circle = result.collider
		if is_yang_mode:
			circle.cycle_color()
		else:
			circle.queue_free()

func _get_simplified_points() -> PoolVector2Array:
	# 简化轨迹点（每5个点取1个）
	var simplified = [drag_start_pos]
	for i in range(0, drag_points.size(), 5):
		simplified.append(drag_points[i])
	return PoolVector2Array(simplified)
