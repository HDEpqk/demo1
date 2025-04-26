extends "res://scripts/Lianpu.gd"

onready var bgmSprite=$Sprite
onready var bgmLable=$SelectionLabel
onready var isBgmOn:bool=DataMgr.get_setting("audio","music_enabled")

func _ready():
	# 安全初始化图片
	if bgmSprite!= null:
		bgmSprite.texture=load("res://art/bgmOn.png")
	else:
		printerr("bgmSprite为空")
	#该脸谱应该静止
	speed=0
	if bgmLable!= null:
		bgmLable.text="音乐"
	else:
		printerr("bgmSprite为空")



func init(_color:Color, pos:Vector2):
	pass
	

func cycle_color():
	isBgmOn=!isBgmOn
	if isBgmOn:
		bgmSprite.texture=load("res://art/bgmOn.png")
	else:
		bgmSprite.texture=load("res://art/bgmOff.png")
	DataMgr.set_setting("audio","music_enabled",isBgmOn)




func queue_free():
	pass
