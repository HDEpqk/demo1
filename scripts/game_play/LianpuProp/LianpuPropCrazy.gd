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
	#发送疯狂时间的开始事件
	EventBus.fire_event("crazy_time_begin",8)
	#handle_element_counter_sfx()#播放死亡音效
	#播放joker音效
	$AudioStreamPlayer.stream=load("res://audio/sfx/joker_laugh.tres")
	$AudioStreamPlayer.play()
	
	handle_score_operation()#加分
	handle_energy_operation()#根据运算类型进行不同运算
	

func _on_AudioStreamPlayer_finished():
	call_deferred("queue_free")  # 延迟安全销毁
