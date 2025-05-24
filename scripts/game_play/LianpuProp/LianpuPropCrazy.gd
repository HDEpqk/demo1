extends "res://scripts/game_play/LianpuProp/LianpuProp.gd"


func init(_mode:int, pos:Vector2,_reward_score:float,_speed:float):
	.init(_mode,pos,_reward_score,_speed)
	taiji_mode=GameEnums.TaijiMode.jin
	#关闭死亡动画sprite
	$AnimatedDeath.visible=false	
func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set_deferred("disabled", true)
	$AnimatedSprite.visible=false
	#发送疯狂时间的开始事件
	EventBus.fire_event("crazy_time_begin",5)
	#播放joker音效
	$AudioStreamPlayer.stream=load("res://audio/sfx/joker_laugh.tres")
	$AudioStreamPlayer.play()
	#加分
	var new_score=Global.score+reward_score*Global.multiple
	EventBus.fire_event("global_score_changed",new_score)

func _on_AudioStreamPlayer_finished():
	call_deferred("queue_free")  # 延迟安全销毁
