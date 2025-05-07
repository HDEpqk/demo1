extends "res://scripts/game_play/Lianpu.gd"



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
			$SelectionLabel.text="5分钟限时挑战"
		GameEnums.TaijiMode.jin:
			$SelectionLabel.text="无尽挑战"
			

func queue_free():
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			get_tree().change_scene("res://scene/game_scene/game/Game_5min.tscn")
		GameEnums.TaijiMode.jin:
			get_tree().change_scene("res://scene/game_scene/game/Game_wujin.tscn")	
	.queue_free()
