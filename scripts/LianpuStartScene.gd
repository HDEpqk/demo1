extends "res://scripts/Lianpu.gd"



func _ready():
	# 安全初始化
	taiji_mode=GameEnums.TaijiMode.huo
	#该脸谱应该静止
	speed=0


	

func cycle_color():
	.cycle_color()
	update_selection_label()

func update_selection_label():
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			$SelectionLabel.text="开始游戏"
		GameEnums.TaijiMode.jin:
			$SelectionLabel.text="游戏教程"
		GameEnums.TaijiMode.mu:
			$SelectionLabel.text="游戏设置"
		GameEnums.TaijiMode.shui:
			$SelectionLabel.text="退出游戏"

func queue_free():
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			#跳转到游戏选择界面
			get_tree().change_scene("res://scene/ChooseScene.tscn")
		GameEnums.TaijiMode.jin:
			#跳转到游戏教程界面
			get_tree().change_scene("res://scene/StartScene.tscn")
		GameEnums.TaijiMode.mu:
			#跳转到游戏设置界面
			get_tree().change_scene("res://scene/SettingScene.tscn")
		GameEnums.TaijiMode.shui:
			#退出游戏
			get_tree().quit()
	.queue_free()
