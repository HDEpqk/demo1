extends Node2D


func _ready():
	#设置背景的缩放
	var viewport_size = get_viewport().size
	var texture_size = $BG.get_size()
	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	$BG.rect_scale = Vector2(scale_x, scale_y)
	#设置场景脸谱的位置
	$LianpuStartScene.position=viewport_size/2
	#设置center的位置
	$Center.position.x=viewport_size.x/2
	$Center.position.y=viewport_size.y-100
	#注册设置面板
	var setting_panel=$SettingPanel
	UiMgr.register_control("SettingPanel",setting_panel)
