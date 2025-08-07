extends "res://scripts/game_play/LianpuProp/LianpuProp.gd"



func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set_deferred("disabled", true)
	$AnimatedSprite.visible=false
	if !Global.is_invincible:#如果处于疯狂时间不会减速
		EventBus.fire_event("decelerate_spawn_begin",5)
	.handle_death()
