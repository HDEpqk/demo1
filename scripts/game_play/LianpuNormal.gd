extends "res://scripts/game_play/Lianpu.gd"


func init(_mode:int, pos:Vector2):
	.init(_mode,pos)
	#初始能量值
	if Global.random!=null:
		energy=generate_non_zero_random(-10,10)
		print("初始能量："+str(energy))
	print("初始运算类型："+str(operation_type))
	update_energy_label()
	#获取AnimationPlayer
	animation_player=$AnimationPlayer
	#注册AnimationPlayer
	AnimationMgr.register_player("LianpuNormal",animation_player)
	# 初始化随机数种子
	randomize()
	# 获取所有死亡动画的名称
	for anim in animation_player.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	for anim_name in death_animations:
		DebugUtils.log("anim_name="+anim_name)
	# 创建回调函数的 FuncRef
	callback_func = funcref(self,"queue_free")

func cycle_color():
	.cycle_color()
	update_energy_label()

func update_energy_label():
	match operation_type:
		GameEnums.OperationType.jia:
			$EnergyLabel.text="+"+str(energy)
		GameEnums.OperationType.jian:
			$EnergyLabel.text=str(energy)
		GameEnums.OperationType.cheng:
			$EnergyLabel.text="×"+str(energy)
		GameEnums.OperationType.chu:
			$EnergyLabel.text="÷"+str(energy)


func handle_death():
	#根据运算类型进行不同运算
	match operation_type:
		GameEnums.OperationType.jia:
			Global.energy+=energy
		GameEnums.OperationType.jian:
			Global.energy-=energy
		GameEnums.OperationType.cheng:
			Global.energy*=energy
		GameEnums.OperationType.chu:
			if energy==0:
				print("你÷了0所以game over!")
				#跳转到结束界面
				get_tree().change_scene("res://scene/GameOverScene.tscn")
			else:
				Global.energy/=energy
	#更新能量ui
	UiMgr.update_control_data("EnergyCalibration",Global.energy)
	#处理死亡相关逻辑
	DebugUtils.log("处理死亡相关逻辑")
	#关闭碰撞体和图片
	$CollisionShape2D.disabled=true
	$Sprite.visible=false
	
	#根据taiji_mode改变死亡动画的颜色
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			$AnimatedSprite.self_modulate=Color("#e40000")
		GameEnums.TaijiMode.jin:
			$AnimatedSprite.self_modulate=Color("#e6da29")
		GameEnums.TaijiMode.mu:
			$AnimatedSprite.self_modulate=Color("#28c641")
		GameEnums.TaijiMode.shui:
			$AnimatedSprite.self_modulate=Color("#2d93dd") 
	#打开AnimatedSprite
	$AnimatedSprite.visible=true
	#随机播放死亡动画
	if death_animations.size() > 0:
		# 随机选择一个死亡动画
		var random_index = randi() % death_animations.size()
		var random_animation:String = death_animations[random_index]
		
		#连接动画完成信号
		#$AnimatedSprite.connect("animation_finished", self, "_on_animation_finished", [], CONNECT_ONESHOT)
		#播放随机选择的动画
		$AnimationPlayer.play(random_animation)
	else:
		print("No death animations found.")

func _on_animation_finished():
	DebugUtils.log("处理动画播放完成逻辑")
	call_deferred("queue_free")  # 延迟安全销毁
