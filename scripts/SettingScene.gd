extends Node2D

func _ready():
	#设置背景的缩放
	var viewport_size = get_viewport().size
	var texture_size = $BG.get_size()
	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	$BG.rect_scale = Vector2(scale_x, scale_y)
	#设置脸谱的位置
	$LianpuBGM.position.x=viewport_size.x/2-100
	$LianpuBGM.position.y=viewport_size.y/2
	$LianpuSFX.position.x=viewport_size.x/2+100
	$LianpuSFX.position.y=viewport_size.y/2
	
	#设置center的位置
	$Center.position.x=viewport_size.x/2
	$Center.position.y=viewport_size.y-100
