extends Area2D

# 节点引用
onready var sprite = $Sprite
onready var collision_shape = $CollisionShape2D
onready var ui = get_node("/root/Main/UI")

# 配置参数

#var base_size := Vector2(64, 64)  # 矩形基础尺寸

func _ready():
	# 初始化碰撞形状
#	collision_shape.shape = RectangleShape2D.new()
#	collision_shape.shape.extents = base_size / 2
	# 获取视口（屏幕）的尺寸
	var viewport_size = get_viewport().size
	# 将节点位置设置为屏幕中心
	position = viewport_size / 2
	# 连接信号
	connect("body_entered", self, "_on_body_entered")
	update_yinyang_image(false)
	
func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.queue_free()  # 销毁敌人


func play_hit_effect():
	# 添加视觉反馈
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1,0,0,1), 0.1)
	tween.tween_property(sprite, "modulate", Color(1,1,1,1), 0.3)


func update_yinyang_image(var is_yang_mode:bool):
	#切换阴阳模式图像
	if is_yang_mode:
		$Sprite.texture=load("res://art/yangTaiJi.png")
	else:
		$Sprite.texture=load("res://art/yinTaiJi.png")
			
