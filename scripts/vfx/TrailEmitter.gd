extends Node2D

# 获取 CPUParticles2D 节点
onready var particles = $Node2D/CPUParticles2D

# 记录鼠标左键是否被按下
var is_mouse_pressed = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				# 鼠标左键按下
				is_mouse_pressed = true
				particles.emitting = true
			else:
				# 鼠标左键释放
				is_mouse_pressed = false
				particles.emitting = false

func _process(delta):
	if is_mouse_pressed:
		# 获取鼠标全局位置
		var mouse_position = get_global_mouse_position()
		# 设置粒子发射器的全局位置为鼠标位置
		global_position = mouse_position    
