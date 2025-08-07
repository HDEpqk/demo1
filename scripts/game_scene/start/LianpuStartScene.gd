extends "res://scripts/game_play/Lianpu.gd"



func _ready():
	# 安全初始化
	taiji_mode=GameEnums.TaijiMode.huo
	energy=1#赋值成1避免除以0
	#该脸谱应该静止
	speed=0
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	$AnimatedDeath.visible=false
	update_selection_label()

func cycle_taiji_mode():
	var index=taiji_order.find(taiji_mode)
	taiji_mode=taiji_order[(index+1)%taiji_order.size()]
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

func update_selection_label():
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			$SelectionLabel.text="开始游戏"
			$SelectionLabel.self_modulate=Color("#e40000")
		GameEnums.TaijiMode.jin:
			$SelectionLabel.text="游戏排行"
			$SelectionLabel.self_modulate=Color("#e6da29")			
		GameEnums.TaijiMode.mu:
			$SelectionLabel.text="游戏设置"
			$SelectionLabel.self_modulate=Color("#28c641")			
		GameEnums.TaijiMode.shui:
			$SelectionLabel.text="开发名单"
			$SelectionLabel.self_modulate=Color("#2d93dd")			

func handle_death():
	#关闭碰撞体和图片
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite.visible=false
	$SelectionLabel.visible=false
	.handle_death()


func _on_animation_finished():
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			#跳转到游戏选择界面
			SceneMgr.change_scene("res://scene/game_scene/choose/ChooseScene.tscn")
		GameEnums.TaijiMode.jin:
			#显示游戏排行榜
			SceneMgr.change_scene("res://scene/ui/LeaderBoarder.tscn")
		GameEnums.TaijiMode.mu:
			#跳转到游戏设置界面
			SceneMgr.change_scene("res://scene/game_scene/setting/SettingScene.tscn")
		GameEnums.TaijiMode.shui:
			#开发者名单
			SceneMgr.change_scene("res://scene/game_scene/developer/DeveloperScene.tscn")
