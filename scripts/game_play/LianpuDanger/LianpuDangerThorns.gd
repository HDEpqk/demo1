extends "res://scripts/game_play/LianpuDanger/LianpuDanger.gd"


func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set("disabled", true)
	$Area2D/ThornsCollision.set("disabled", true)
	$AnimatedSprite.visible=false
	.handle_death()


func _on_Area2D_area_entered(area):
	if area.is_in_group("player"):
		$BodyCollision.set("disabled", true)
		


func _on_Area2D_area_exited(area):
	if area.is_in_group("player"):
		$BodyCollision.set("disabled", false)
