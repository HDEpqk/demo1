extends "res://scripts/game_play/Lianpu.gd"

onready var sfxSprite=$Sprite
onready var sfxLable=$SelectionLabel
onready var isSfxOn:bool=DataMgr.get_setting("audio","sound_enabled")

func _ready():
	# 安全初始化图片
	if sfxSprite!= null:
		if isSfxOn:
			sfxSprite.texture=load("res://art/ui/setting/sfxOn.png")
		else:
			sfxSprite.texture=load("res://art/ui/setting/sfxOff.png")
	else:
		printerr("bgmSprite为空")
	#该脸谱应该静止
	speed=0
	if sfxLable!= null:
		sfxLable.text="音效"
	else:
		printerr("sfxLable为空")
	$SelectionLabel.self_modulate=Color.black



func cycle_taiji_mode():
	isSfxOn=!isSfxOn
	if isSfxOn:
		sfxSprite.texture=load("res://art/ui/setting/sfxOn.png")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)#取消静音
	else:
		sfxSprite.texture=load("res://art/ui/setting/sfxOff.png")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)#静音

	DataMgr.set_setting("audio","sound_enabled",isSfxOn)


func handle_death():
	pass
