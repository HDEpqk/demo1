extends "res://scripts/game_play/LianpuDanger/LianpuDanger.gd"

func _ready():
	._ready()
	#$Area2D.connect("area_entered", self, "_on_area_entered")

func init(_mode:int, pos:Vector2,_reward_score:float,_speed:float):
	.init(_mode,pos,_reward_score,_speed)
	taiji_mode=GameEnums.TaijiMode.mu
	
func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set_deferred("disabled", true)
	$Area2D/ThornsCollision.set_deferred("disabled", true)
	$AnimatedSprite.visible=false
	.handle_death()

#func _on_area_entered(area):
#	DebugUtils.log("area entered")
#	if area.is_in_group("player"):
#		DebugUtils.log("player hurt")
