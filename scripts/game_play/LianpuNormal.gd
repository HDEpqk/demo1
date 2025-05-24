extends "res://scripts/game_play/Lianpu.gd"

func _ready():
	._ready()
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	

func init(_mode:int, pos:Vector2,_reward_score:float,_speed:float):
	.init(_mode,pos,_reward_score,_speed)
	#初始能量值
	var	random = RandomNumberGenerator.new()
	random.randomize()
	energy=random.randi_range(1,10)
	print("初始能量："+str(energy))
	update_operation_type(_mode)
	update_energy_label()
	print("初始运算类型："+str(operation_type))
	if sprite != null:
		update_texture()
	else:
		printerr("Sprite节点初始化失败")
	#关闭死亡动画sprite
	$AnimatedDeath.visible=false
	

func cycle_taiji_mode():
	.cycle_taiji_mode()
	update_operation_type(taiji_mode)
	if sprite != null:
		update_texture()
	else:
		printerr("模式切换失败：Sprite节点丢失")
	update_energy_label()
	
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
func update_energy_label():
	match operation_type:
		GameEnums.OperationType.jia:
			$EnergyLabel.text="+"+str(energy)
		GameEnums.OperationType.jian:
			$EnergyLabel.text="-"+str(energy)
		GameEnums.OperationType.cheng:
			$EnergyLabel.text="×"+str(energy)
		GameEnums.OperationType.chu:
			$EnergyLabel.text="÷"+str(energy)


func handle_death():
	#关闭碰撞体和图片
	$CollisionShape2D.set("disabled", true)
	$Sprite.visible=false
	var new_energy_value=0
	#根据运算类型进行不同运算
	match operation_type:
		GameEnums.OperationType.jia:
			new_energy_value=Global.energy+energy
		GameEnums.OperationType.jian:
			new_energy_value=Global.energy-energy
		GameEnums.OperationType.cheng:
			new_energy_value=Global.energy*energy
		GameEnums.OperationType.chu:
			if energy==0:
				DebugUtils.log("你÷了0所以game over!")
				#跳转到结束界面
				get_tree().change_scene("res://scene/GameOverScene.tscn")
			else:
				new_energy_value=Global.energy/energy
	EventBus.fire_event("global_energy_changed",new_energy_value)

	.handle_death()


