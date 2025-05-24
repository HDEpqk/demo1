extends "res://scripts/game_play/LianpuDanger/LianpuDanger.gd"


func init(_mode:int, pos:Vector2,_reward_score:float,_speed:float):
	.init(_mode,pos,_reward_score,_speed)
	taiji_mode=GameEnums.TaijiMode.shui
	#关闭死亡动画sprite
	$AnimatedDeath.visible=false	
	#开启普通动画
	$AnimatedSprite.visible=true
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
		#随机播放死亡动画
		if death_animations.size() > 0:
			# 随机选择一个死亡动画
			var random_index = randi() % death_animations.size()
			var random_animation:String = death_animations[random_index]

			#播放随机选择的动画
			$AnimationPlayer.play(random_animation)
		else:
			print("No death animations found.")
		#播放死亡音效
		handle_element_counter_sfx()
		#加分
		var new_score=Global.score+reward_score*Global.multiple
		EventBus.fire_event("global_score_changed",new_score)
	else:
		#关闭碰撞体
		$BodyCollision.set("disabled", true)
		$AnimationPlayer.play("dodge")
		#播放水闪避音效
		$AudioStreamPlayer.stream=load("res://audio/sfx/shui_dodge.tres")
		$AudioStreamPlayer.play()
