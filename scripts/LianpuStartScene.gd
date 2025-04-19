extends "res://scripts/Lianpu.gd"



func _ready():
	# 安全初始化颜色
	color =Color.red
	#该脸谱应该静止
	speed=0



func init(_color:Color, pos:Vector2):
	pass
	

func cycle_color():
	.cycle_color()
	update_selection_label()

func update_selection_label():
	match color:
		Color.red:
			$SelectionLabel.text="开始游戏"
		Color.yellow:
			$SelectionLabel.text="游戏教程"
		Color.green:
			$SelectionLabel.text="游戏设置"
		Color.blue:
			$SelectionLabel.text="退出游戏"

func queue_free():
#根据颜色类型进行界面跳转
	match color:
		Color.red:
			#跳转到游戏选择界面
			get_tree().change_scene("res://scene/ChooseScene.tscn")
			pass
		Color.yellow:
			#跳转到游戏教程界面(暂时跳转到游戏开始界面)
			get_tree().change_scene("res://scene/StartScene.tscn")
			pass
		Color.green:
			#跳转到游戏设置界面(暂时跳转到游戏开始界面)
			get_tree().change_scene("res://scene/StartScene.tscn")
			pass
		Color.blue:
			#退出游戏
			get_tree().quit()
			pass
	.queue_free()
