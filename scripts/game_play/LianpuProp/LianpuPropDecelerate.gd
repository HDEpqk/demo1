extends "res://scripts/game_play/LianpuProp/LianpuProp.gd"


func init(_mode:int, pos:Vector2,_reward_score:float,_speed:float):
	.init(_mode,pos,_reward_score,_speed)
	taiji_mode=GameEnums.TaijiMode.shui
	#关闭死亡动画sprite
	$AnimatedDeath.visible=false	
func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set_deferred("disabled", true)
	$AnimatedSprite.visible=false
	EventBus.fire_event("decelerate_spawn_begin",5)
	.handle_death()
