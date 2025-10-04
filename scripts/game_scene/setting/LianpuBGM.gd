extends "res://scripts/game_play/Lianpu.gd"

onready var bgmSprite=$Sprite
onready var bgmLable=$SelectionLabel
onready var isBgmOn:bool=DataMgr.get_setting("audio","music_enabled")

func _ready():
	# 安全初始化图片
	if bgmSprite!= null:
		if isBgmOn:
			bgmSprite.texture=load("res://art/ui/setting/bgmOn.png")
		else:
			bgmSprite.texture=load("res://art/ui/setting/bgmOff.png")
	else:
		printerr("bgmSprite为空")
	#该脸谱应该静止
	speed=0
	if bgmLable!= null:
		bgmLable.text="音乐"
	else:
		printerr("bgmSprite为空")
	#$SelectionLabel.self_modulate=Color.black
	


	

func cycle_taiji_mode():
	isBgmOn=!isBgmOn
	if isBgmOn:
		bgmSprite.texture=load("res://art/ui/setting/bgmOn.png")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)#取消静音
	else:
		bgmSprite.texture=load("res://art/ui/setting/bgmOff.png")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)#静音
	DataMgr.set_setting("audio","music_enabled",isBgmOn)




func handle_death():
	pass
