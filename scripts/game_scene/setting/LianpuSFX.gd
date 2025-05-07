extends "res://scripts/game_play/Lianpu.gd"

onready var sfxSprite=$Sprite
onready var sfxLable=$SelectionLabel
onready var isSfxOn:bool=DataMgr.get_setting("audio","sound_enabled")

func _ready():
	# 安全初始化图片
	if sfxSprite!= null:
		sfxSprite.texture=load("res://art/ui/setting/sfxOn.png")
	else:
		printerr("bgmSprite为空")
	#该脸谱应该静止
	speed=0
	if sfxLable!= null:
		sfxLable.text="音效"
	else:
		printerr("sfxLable为空")




func cycle_color():
	isSfxOn=!isSfxOn
	if isSfxOn:
		sfxSprite.texture=load("res://art/ui/setting/sfxOn.png")
	else:
		sfxSprite.texture=load("res://art/ui/setting/sfxOff.png")

	DataMgr.set_setting("audio","sound_enabled",isSfxOn)


func queue_free():
	pass
