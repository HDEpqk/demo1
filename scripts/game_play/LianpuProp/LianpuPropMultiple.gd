extends "res://scripts/game_play/LianpuProp/LianpuProp.gd"



	
func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set_deferred("disabled", true)
	$AnimatedSprite.visible=false
	#更新lianpu倍数
	Global.set_lianpu_multiple(2)
	EventBus.fire_event_3param("global_multiple_changed",Global.get_multiple(),true,5)
	.handle_death()
