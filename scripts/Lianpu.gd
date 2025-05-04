extends RigidBody2D

# 将颜色变量替换为太极模式枚举
var taiji_mode: int  # 类型为GameEnums.TaijiMode 
export var speed = 50
var energy:float
var operation_type # 运算类型

# 定义太极模式循环顺序（与原颜色顺序对应）
var taiji_order = [
	GameEnums.TaijiMode.huo,  # 原Color.red
	GameEnums.TaijiMode.jin,  # 原Color.yellow 
	GameEnums.TaijiMode.mu,   # 原Color.green
	GameEnums.TaijiMode.shui  # 原Color.blue
]

onready var sprite:Sprite = $Sprite

func _ready():
	# 获取场景树相关逻辑保持不变
	var tree = get_tree()
	var current_scene = tree.get_current_scene()
	var root_node_name = current_scene.name
	print("当前场景根节点的名字是: ", root_node_name)

func init(_mode:int, pos:Vector2):
	# 验证模式有效性
	if not taiji_order.has(_mode):
		printerr("无效的太极模式:", _mode)
		_mode = taiji_order[0]  # 默认火模式
	
	taiji_mode = _mode
	update_operation_type()
	
	var viewport_size = get_viewport().size
	position = pos
	
	if sprite != null:
		update_texture()
	else:
		printerr("Sprite节点初始化失败")
	
	# 移动逻辑保持不变
	linear_velocity = (Vector2(viewport_size.x/2, viewport_size.y/2) - pos).normalized() * speed

func cycle_color():
	# 改为循环太极模式
	var current_index = taiji_order.find(taiji_mode)
	var next_index = (current_index + 1) % taiji_order.size()
	taiji_mode = taiji_order[next_index]
	
	update_operation_type()
	if sprite != null:
		update_texture()
	else:
		printerr("模式切换失败：Sprite节点丢失")

func update_texture():
	# 根据太极模式加载对应贴图
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			sprite.texture=load("res://art/lianpu/LianpuNormal/red_shadow_64.png")
		GameEnums.TaijiMode.jin:
			sprite.texture=load("res://art/lianpu/LianpuNormal/yellow_shadow_64.png")
		GameEnums.TaijiMode.mu:
			sprite.texture=load("res://art/lianpu/LianpuNormal/green_shadow_64.png")
		GameEnums.TaijiMode.shui:
			sprite.texture=load("res://art/lianpu/LianpuNormal/blue_shadow_64.png")

func update_operation_type():
	# 根据太极模式设置运算类型
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			operation_type=GameEnums.OperationType.jia  # 火对应加
		GameEnums.TaijiMode.jin:
			operation_type=GameEnums.OperationType.jian # 金对应减
		GameEnums.TaijiMode.mu:
			operation_type=GameEnums.OperationType.cheng # 木对应乘
		GameEnums.TaijiMode.shui:
			operation_type=GameEnums.OperationType.chu   # 水对应除

# 释放方法保持不变
func queue_free():
	sleeping = true
	$CollisionShape2D.set_deferred("disabled", true)
	.queue_free()
