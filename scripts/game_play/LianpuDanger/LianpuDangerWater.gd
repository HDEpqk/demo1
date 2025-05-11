extends "res://scripts/game_play/LianpuDanger/LianpuDanger.gd"


func init(_mode:int, pos:Vector2,_reward_score:float,_speed:float):
	.init(_mode,pos,_reward_score,_speed)
	taiji_mode=GameEnums.TaijiMode.shui
	
func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set_deferred("disabled", true)
	$AnimatedSprite.visible=false
	.handle_death()
