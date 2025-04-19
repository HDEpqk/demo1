extends "res://scripts/Lianpu.gd"



func _ready():
	# 颜色循环顺序配置
	color_order = [Color.red,Color.yellow]
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
			$SelectionLabel.text="返回选择界面"
		Color.yellow:
			$SelectionLabel.text="返回开始界面"

func queue_free():
#根据颜色类型进行界面跳转
	match color:
		Color.red:
			#跳转到选择场景
			get_tree().change_scene("res://scene/ChooseScene.tscn")
		Color.yellow:
			#跳转到开始场景
			get_tree().change_scene("res://scene/StartScene.tscn")
	.queue_free()
