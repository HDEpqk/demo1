extends "res://scripts/game_play/LianpuDanger/LianpuDanger.gd"


func init(_mode:int, pos:Vector2,_reward_score:float,_speed:float):
	.init(_mode,pos,_reward_score,_speed)
	taiji_mode=GameEnums.TaijiMode.mu
	#关闭死亡动画sprite
	$AnimatedDeath.visible=false
	#开启普通动画
	$AnimatedSprite.visible=true
func handle_death():
	#关闭碰撞体和图片
	$Area2D/ThornsCollision.set("disabled", true)
	$BodyCollision.set("disabled", true)
	$AnimatedSprite.visible=false
	.handle_death()
