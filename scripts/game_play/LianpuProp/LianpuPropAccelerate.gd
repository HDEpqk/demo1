extends "res://scripts/game_play/LianpuProp/LianpuProp.gd"



func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set_deferred("disabled", true)
	$AnimatedSprite.visible=false
	EventBus.fire_event("accelerate_spawn_begin",5)
	.handle_death()
