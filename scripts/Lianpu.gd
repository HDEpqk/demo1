extends RigidBody2D
var color: Color
export var speed = 50
var energy:float
enum OperationType {
jia,
jian,
cheng,
chu
}
var operation_type#运算类型

# 预加载粒子特效场景
#const FADE_EFFECT = preload("res://effects/FadeParticles.tscn")

# 颜色循环顺序配置
var color_order = [Color.red,Color.yellow,Color.green, Color.blue]
onready var sprite:Sprite = $Sprite

func _ready():
	# 获取场景树
	var tree = get_tree()
	# 获取当前活动场景
	var current_scene = tree.get_current_scene()
	# 获取当前场景根节点的名字
	var root_node_name = current_scene.name
	print("当前场景根节点的名字是: ", root_node_name)

func init(_color:Color, pos:Vector2):
	# 安全初始化颜色
	color = _color if color_order.has(_color) else Color.red
	#根据颜色赋予运算类型
	update_operation_type()

		# 获取视口（屏幕）的尺寸
	var viewport_size = get_viewport().size

	position = pos
	if sprite != null:
		update_texture()
	else:
		printerr("Sprite节点初始化失败")
	# 设置朝中心移动的初速度
	linear_velocity = (Vector2(viewport_size.x/2, viewport_size.y/2) - pos).normalized() * speed
	

func cycle_color():
	# 获取当前颜色索引
	var current_index = color_order.find(color)
	# 计算下一个颜色索引（循环）
	var next_index = (current_index + 1) % color_order.size()
	# 更新颜色状态
	color = color_order[next_index]

#	# 随机更新颜色状态
#	color = COLOR_ORDER[randi() % COLOR_ORDER.size()]
	update_operation_type()
	
	if sprite != null:
		update_texture()
	else:
		printerr("颜色切换失败：Sprite节点丢失")

func update_texture():
	match color:
		Color.red:
			sprite.texture=load("res://art/red.png")
		Color.yellow:
			sprite.texture=load("res://art/yellow.png")
		Color.green:
			sprite.texture=load("res://art/green.png")
		Color.blue:
			sprite.texture=load("res://art/blue.png")

	
#根据改变后的颜色赋予运算类型
func update_operation_type():
	match color:
		Color.red:
			operation_type=OperationType.jia
		Color.yellow:
			operation_type=OperationType.jian
		Color.green:
			operation_type=OperationType.cheng
		Color.blue:
			operation_type=OperationType.chu
	


func queue_free():
	
	# 停止物理模拟
	sleeping = true
	# 禁用碰撞检测
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 播放消失特效
#    var effect = FADE_EFFECT.instance()
#    effect.position = global_position
#    get_parent().add_child(effect)
#    effect.emitting = true
	
	# 延迟释放确保特效播放
	#yield(get_tree().create_timer(0.5), "timeout")
	# 调用父类释放方法
	.queue_free()

