extends "res://scripts/game_play/LianpuNormal/LianpuNormal.gd"



onready var lianpu_type_order=["normal_red","normal_yellow","normal_green","normal_blue"]

func _ready():
	lianpu_type="normal_red"
	# 安全初始化
	taiji_mode=GameEnums.TaijiMode.huo
	#该脸谱应该静止
	speed=0
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	$AnimatedDeath.visible=false

	#初始脸谱能量字体大小
	if $EnergyLabel!=null:
		$EnergyLabel.set_scale($EnergyLabel.get_scale()*1.5)
	change_energy_and_operation()
	EventBus.connect("wuxing_generation_available",self,"_on_wuxing_generation_available")

func change_energy_and_operation():
	var	random = RandomNumberGenerator.new()
	random.randomize()
	energy=random.randi_range(1,10)
	
	update_operation_type(taiji_mode)
	update_energy_label()
	#脸谱能量字体跟随太极模式颜色
	init_energy_label_color()

func _on_death_animation_finished():
	#开启碰撞体和图片
	$BodyCollision.set("disabled", false)
	$Sprite.visible=true
	$EnergyLabel.visible=true
	$AnimatedDeath.visible=false
	is_dying=false
	

	change_energy_and_operation()
	
func cycle_taiji_mode():
	var index=taiji_order.find(taiji_mode)
	taiji_mode=taiji_order[(index+1)%taiji_order.size()]
	update_operation_type(taiji_mode)
	if sprite != null:
		update_texture()
	else:
		printerr("模式切换失败：Sprite节点丢失")
	#更换lianpu_type
	var index2=lianpu_type_order.find(lianpu_type)
	lianpu_type=lianpu_type_order[(index2+1)%lianpu_type_order.size()]
	change_energy_and_operation()


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
