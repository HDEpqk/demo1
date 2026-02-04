extends "res://scripts/game_play/LianpuProp/LianpuProp.gd"



	
func handle_death():
	if !Global.is_invincible:
		#如果全局能量大于或小于脸谱能量，则执行消除逻辑
		if operation_type==GameEnums.OperationType.dayu and Global.energy<energy:return
		if operation_type==GameEnums.OperationType.xiaoyu and Global.energy>energy:return
	#关闭碰撞体和图片
	$BodyCollision.set_deferred("disabled", true)
	$AnimatedSprite.visible=false
	#更新lianpu倍数
	Global.set_lianpu_multiple(2)
	EventBus.fire_event_3param("global_multiple_changed",Global.get_multiple(),true,5)
	.handle_death()
