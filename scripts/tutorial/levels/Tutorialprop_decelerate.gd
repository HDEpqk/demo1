extends "res://scripts/game_play/LianpuProp/LianpuProp.gd"

func _ready():
	# 安全初始化
	taiji_mode=GameEnums.TaijiMode.shui
	energy=0
	#该脸谱应该静止
	speed=0
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	$AnimatedDeath.visible=false
	if $EnergyLabel!=null:
		$EnergyLabel.set_scale($EnergyLabel.get_scale()*1.5)
	change_energy_and_operation()

func change_energy_and_operation():

	
	update_operation_type(taiji_mode)
	update_energy_label()
	#脸谱能量字体跟随太极模式颜色
	init_energy_label_color()

func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set_deferred("disabled", true)
	$AnimatedSprite.visible=false
	if !Global.is_invincible:#如果处于疯狂时间不会减速
		EventBus.fire_event("decelerate_spawn_begin",5)
	.handle_death()

func _on_death_animation_finished():
	$EnergyLabel.visible=true
	#开启碰撞体和图片
	$BodyCollision.set("disabled", false)
	$AnimatedSprite.visible=true
	$AnimatedDeath.visible=false
	is_dying=false
	change_energy_and_operation()
