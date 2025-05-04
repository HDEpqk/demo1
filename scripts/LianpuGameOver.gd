extends "res://scripts/Lianpu.gd"



func _ready():
	# mode循环顺序配置
	taiji_order = [GameEnums.TaijiMode.huo,  # 原Color.red
	GameEnums.TaijiMode.jin,]# 原Color.yellow 
	# 安全初始化
	taiji_mode =taiji_order[0]
	#该脸谱应该静止
	speed=0


func cycle_color():
	.cycle_color()
	update_selection_label()

func update_selection_label():
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			$SelectionLabel.text="返回选择界面"
		GameEnums.TaijiMode.jin:
			$SelectionLabel.text="返回开始界面"

func queue_free():
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			#跳转到选择场景
			get_tree().change_scene("res://scene/ChooseScene.tscn")
		GameEnums.TaijiMode.jin:
			#跳转到开始场景
			get_tree().change_scene("res://scene/StartScene.tscn")
	.queue_free()
