extends "res://scripts/game_play/Lianpu.gd"

onready var return_sprite=$Sprite
onready var return_label=$SelectionLabel

func _ready():
	# 安全初始化图片
	if return_sprite!= null:
		return_sprite.texture=load("res://art/ui/setting/returnBtn.png")
	else:
		printerr("return_sprite为空")
	#该脸谱应该静止
	speed=0
	if return_label!= null:
		return_label.text="返回"
	else:
		printerr("return_label为空")



	

func cycle_color():
	pass


func queue_free():
	get_tree().change_scene("res://scene/game_scene/start/StartScene.tscn")
	.queue_free()
