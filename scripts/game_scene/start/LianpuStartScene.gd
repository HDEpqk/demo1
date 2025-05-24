extends "res://scripts/game_play/Lianpu.gd"



func _ready():
	# 安全初始化
	taiji_mode=GameEnums.TaijiMode.huo
	#该脸谱应该静止
	speed=0
	# 初始化随机数种子
	randomize()
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	$AnimatedDeath.visible=false

func cycle_taiji_mode():
	.cycle_taiji_mode()
	update_operation_type(taiji_mode)
	if sprite != null:
		update_texture()
	else:
		printerr("模式切换失败：Sprite节点丢失")
	update_selection_label()

func update_texture():
	# 根据太极模式加载对应贴图
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			sprite.texture=load("res://art/lianpu/LianpuNormal/red_shadow_64.png")
		GameEnums.TaijiMode.jin:
			sprite.texture=load("res://art/lianpu/LianpuNormal/yellow_shadow_64.png")
		GameEnums.TaijiMode.mu:
			sprite.texture=load("res://art/lianpu/LianpuNormal/green_shadow_64.png")
		GameEnums.TaijiMode.shui:
			sprite.texture=load("res://art/lianpu/LianpuNormal/blue_shadow_64.png")

func update_operation_type(mode:int):
	# 根据太极模式设置运算类型
	match mode:
		GameEnums.TaijiMode.huo:
			operation_type=GameEnums.OperationType.jia  # 火对应加
		GameEnums.TaijiMode.jin:
			operation_type=GameEnums.OperationType.jian # 金对应减
		GameEnums.TaijiMode.mu:
			operation_type=GameEnums.OperationType.cheng # 木对应乘
		GameEnums.TaijiMode.shui:
			operation_type=GameEnums.OperationType.chu   # 水对应除

func update_selection_label():
	match operation_type:
		GameEnums.OperationType.jia:
			$SelectionLabel.text="开始游戏"
		GameEnums.OperationType.jian:
			$SelectionLabel.text="游戏教程"
		GameEnums.OperationType.cheng:
			$SelectionLabel.text="游戏设置"
		GameEnums.OperationType.chu:
			$SelectionLabel.text="退出游戏"

func handle_death():
	#关闭碰撞体和图片
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite.visible=false
	.handle_death()


func _on_animation_finished():
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			#跳转到游戏选择界面
			get_tree().change_scene("res://scene/game_scene/choose/ChooseScene.tscn")
		GameEnums.TaijiMode.jin:
			#跳转到游戏教程界面
			get_tree().change_scene("res://scene/game_scene/start/StartScene.tscn")
		GameEnums.TaijiMode.mu:
			#跳转到游戏设置界面
			get_tree().change_scene("res://scene/game_scene/setting/SettingScene.tscn")
		GameEnums.TaijiMode.shui:
			#退出游戏
			get_tree().quit()
