extends "res://scripts/game_play/LianpuDanger/LianpuDanger.gd"



func handle_death_water(isCenter:bool):
	if isCenter:
		#根据taiji_mode改变死亡动画的颜色
		match taiji_mode:
			GameEnums.TaijiMode.huo:
				$AnimatedDeath.self_modulate=Color("#e40000")
			GameEnums.TaijiMode.jin:
				$AnimatedDeath.self_modulate=Color("#e6da29")
			GameEnums.TaijiMode.mu:
				$AnimatedDeath.self_modulate=Color("#28c641")
			GameEnums.TaijiMode.shui:
				$AnimatedDeath.self_modulate=Color("#2d93dd") 
		
		#关闭AnimatedSprite
		$AnimatedSprite.visible=false
		#打开AnimatedDeath
		$AnimatedDeath.visible=true
		$EnergyLabel.visible=false#关闭EnergyLabel
		#随机播放死亡动画
		if death_animations.size() > 0:
			# 随机选择一个死亡动画
			var random_index = randi() % death_animations.size()
			var random_animation:String = death_animations[random_index]

			#播放随机选择的动画
			$AnimationPlayer.play(random_animation)
		else:
			print("No death animations found.")
		
		handle_element_counter_sfx()#播放死亡音效
		handle_score_operation()#加分
		handle_energy_operation()#根据运算类型进行不同运算
	else:
		#关闭碰撞体
		$BodyCollision.set("disabled", true)
		$AnimationPlayer.play("dodge")
		$EnergyLabel.visible=false#关闭EnergyLabel		
		#播放水闪避音效
		$AudioStreamPlayer.stream=load("res://audio/sfx/shui_dodge.tres")
		$AudioStreamPlayer.play()
		if Global.taiji_mode==GameEnums.TaijiMode.huo:
			#如果当前太极模式是火触发克制惩罚
			handle_score_operation()

func _on_dodge_animation_finished():
	$EnergyLabel.visible=true#开启EnergyLabel

func handle_energy_operation():
	#根据运算类型进行不同运算
	var new_energy_value=0
	match operation_type:
		GameEnums.OperationType.jia:
			new_energy_value=Global.energy+energy
		GameEnums.OperationType.jian:
			new_energy_value=Global.energy-energy
		GameEnums.OperationType.cheng:
			new_energy_value=Global.energy*energy
		GameEnums.OperationType.chu:
			if energy==0:
				if Global.is_invincible:return
				if Global.is_mu_protect_open:
					EventBus.fire_event("mu_protect_close")
					return
				#跳转到结束界面
				SceneMgr.change_scene_with_info("res://scene/game_scene/end/GameOverScene.tscn","你÷了0┗|｀O′|┛ 嗷~~!")
			else:
				new_energy_value=Global.energy/energy
	#如果不处于无敌模式则进行能量计算
	if !Global.is_invincible:
		EventBus.fire_event("global_energy_changed",new_energy_value)
