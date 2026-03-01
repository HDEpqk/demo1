extends "res://scripts/game_play/Lianpu.gd"



func _ready():
	._ready()
	# 获取所有死亡动画的名称
#	for anim in $AnimationPlayer.get_animation_list():
#		if anim.begins_with("death_"):
#			death_animations.append(anim)
	#设置对象属于第3层
	collision_layer =1<<2
	# 设置对象检测第1层和第4层
	collision_mask = 1 | (1<<3)
	#设置脸谱大小
	#set_scale(Vector2(2,2))
func cycle_taiji_mode():
	pass

func init(dic:Dictionary):
	.init(dic)

	var	random = RandomNumberGenerator.new()
	random.randomize()
	energy=random.randi_range(-1000,1000)

	#DebugUtils.log("初始能量："+str(energy))
	update_energy_label()
	#开启碰撞体
	$BodyCollision.set("disabled", false)

func handle_death():
	if is_dying:return#如果正在死亡则退出避免重复调用
	is_dying=true
	# 切换到死亡层（Player 不检测此层）
	if has_node("Area2D"):
		$Area2D.set_collision_layer(1 << LAYER_DEAD)  # 设置层
		$Area2D.set_collision_mask(0)  # 设置掩码，不检测任何层
	#根据taiji_mode改变死亡动画的颜色
	match taiji_mode:
		GameEnums.TaijiMode.yin:
			$AnimatedDeath.self_modulate=Color.black
		GameEnums.TaijiMode.yang:
			$AnimatedDeath.self_modulate=Color.white
		GameEnums.TaijiMode.huo:
			$AnimatedDeath.self_modulate=Color("#e40000")
		GameEnums.TaijiMode.jin:
			$AnimatedDeath.self_modulate=Color("#e6da29")
		GameEnums.TaijiMode.mu:
			$AnimatedDeath.self_modulate=Color("#28c641")
		GameEnums.TaijiMode.shui:
			$AnimatedDeath.self_modulate=Color("#2d93dd")
		GameEnums.TaijiMode.tu:
			$AnimatedDeath.self_modulate=Color("#b36d41")
		
	$AnimatedDeath.visible=true#打开AnimatedDeath
	#随机播放死亡动画
	if death_animations.size() > 0:
		# 随机选择一个死亡动画
		var random_index = randi() % death_animations.size()
		var random_animation:String = death_animations[random_index]
		#播放随机选择的动画
		$AnimationPlayer.play(random_animation)
	else:
		print("No death animations found.")

	#handle_element_counter_sfx()#播放死亡音效
	handle_score_operation()#加分
	handle_energy_operation()#根据运算类型进行不同运算


func update_operation_type(mode:int):
	# 用Godot内置的randi()替代手动创建RandomNumberGenerator，更简洁
	operation_type = GameEnums.OperationType.dayu if randi() % 2 == 0 else GameEnums.OperationType.xiaoyu
func update_energy_label():
	match operation_type:
		GameEnums.OperationType.dayu:
			$EnergyLabel.text=">"+str(energy)
		GameEnums.OperationType.xiaoyu:
			$EnergyLabel.text="<"+str(energy)

func _on_death_animation_finished():
	pass
