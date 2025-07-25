extends Node2D

onready var lianpu_start_scene=$LianpuStartScene
onready var center = $Center
onready var viewport_size = get_viewport().size

func _ready():
	#设置背景的缩放
	var texture_size = $BG.get_size()
	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	$BG.rect_scale = Vector2(scale_x, scale_y)
	#设置场景脸谱的位置
	lianpu_start_scene.position=viewport_size/2
	#设置center的位置
	center.position.x = viewport_size.x/2
	center.position.y = viewport_size.y/2+130
