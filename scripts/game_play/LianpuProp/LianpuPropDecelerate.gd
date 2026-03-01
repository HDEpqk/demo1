extends "res://scripts/game_play/LianpuProp/LianpuProp.gd"



func handle_death():
	if !Global.is_invincible:
		#如果全局能量大于或小于脸谱能量，则执行消除逻辑
		if operation_type==GameEnums.OperationType.dayu and Global.energy<energy:return
		if operation_type==GameEnums.OperationType.xiaoyu and Global.energy>energy:return
	#关闭碰撞体和图片
	$BodyCollision.set_deferred("disabled", true)
	$AnimatedSprite.visible=false
	$EnergyLabel.visible=false#关闭EnergyLabel
	#if !Global.is_invincible:#如果处于疯狂时间不会减速
	EventBus.fire_event("decelerate_spawn_begin",10)
	#播放音效
	$AudioStreamPlayer.stream=load("res://audio/sfx/decelerate.mp3str")
	$AudioStreamPlayer.play()

	.handle_death()

func _on_AudioStreamPlayer_finished():
	call_deferred("queue_free")  # 延迟安全销毁
