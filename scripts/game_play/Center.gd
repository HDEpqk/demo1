extends Area2D

# 节点引用
onready var sprite = $Sprite
onready var collision_shape = $CollisionShape2D


func _ready():
	# 获取视口（屏幕）的尺寸
	var viewport_size = get_viewport().size
	# 将节点位置设置为屏幕中心
	position = viewport_size / 2
	# 连接信号
	connect("body_entered", self, "_on_body_entered")
	connect("area_entered", self, "_on_area_entered")	
	update_yinyang_image(Global.taiji_mode)
	#订阅太极模式变化的事件
	EventBus.connect("global_taiji_mode_changed",self,"update_yinyang_image")

func _on_body_entered(body):
	DebugUtils.log("body entered")
	if body.is_in_group("lianpu"):
		body.handle_death()  # 销毁敌人

func _on_area_entered(area):
	if area.is_in_group("danger_area"):
		DebugUtils.log("center hurt")

func play_hit_effect():
	# 添加视觉反馈
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1,0,0,1), 0.1)
	tween.tween_property(sprite, "modulate", Color(1,1,1,1), 0.3)


func update_yinyang_image(new_value:int):
	match new_value:
		GameEnums.TaijiMode.yin:
			sprite.texture=preload("res://art/ui/game/taiji_yin.png")
		GameEnums.TaijiMode.yang:
			sprite.texture=preload("res://art/ui/game/taiji_yang.png")
