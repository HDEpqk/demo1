extends "res://scripts/game_play/LianpuDanger/LianpuDanger.gd"


func handle_death():
	#关闭碰撞体和图片
	$Area2D/ThornsCollision.set("disabled", true)
	$BodyCollision.set("disabled", true)
	$AnimatedSprite.visible=false
	.handle_death()
