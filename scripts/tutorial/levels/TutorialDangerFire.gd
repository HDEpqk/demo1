# LianpuDangerFire.gd
extends "res://scripts/game_play/LianpuDanger/LianpuDanger.gd"

#export var rotation_speed := 2.0  # 每秒旋转角度（可编辑器调整）
#
#
#func _physics_process(delta):
#	._physics_process(delta)
#	# 设置角速度 (旋转)
#	angular_velocity = rotation_speed

func _ready():
	# 安全初始化
	taiji_mode=GameEnums.TaijiMode.huo
	#该脸谱应该静止
	speed=0
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	$AnimatedDeath.visible=false

#	#初始脸谱能量字体大小
#	if $EnergyLabel!=null:
#		$EnergyLabel.set_scale($EnergyLabel.get_scale()*1.5)
#	change_energy_and_operation()
#
#func change_energy_and_operation():
#	var	random = RandomNumberGenerator.new()
#	random.randomize()
#	energy=random.randi_range(1,10)
#
#	update_operation_type(taiji_mode)
#	update_energy_label()
#	#脸谱能量字体跟随太极模式颜色
#	init_energy_label_color()


	
#切换到循环动画
func switch_loop_attack():
	$AnimationPlayer.play("loop_attack")
	
func handle_death():
	pass
