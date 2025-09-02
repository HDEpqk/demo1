# LianpuDangerMetal.gd
extends "res://scripts/game_play/LianpuDanger/LianpuDanger.gd"

# 配置参数（可自定义调整）
export var loop_duration := 2    # loop_attack持续时间
export var end_duration := 2     # end_attack持续时间


func init(dic:Dictionary):
	.init(dic)
	# 初始化计时器（替代动态创建方案）
	$LoopTimer.wait_time = loop_duration
	$EndTimer.wait_time = end_duration
func switch_loop_attack():
	$AnimationPlayer.play("loop_attack")
	$LoopTimer.start()  # 启动第一阶段计时

func _on_LoopTimer_timeout():
	$AnimationPlayer.play("end_attack")
	$LoopTimer.stop()
	$EndTimer.start()   # 启动第二阶段计时

func _on_EndTimer_timeout():
	$EndTimer.stop()
	$AnimationPlayer.play("begin_attack")  # 回归初始状态

# 维护原有碰撞和死亡逻辑
func handle_death():
	#暂停所有计时器
	$LoopTimer.stop()
	$EndTimer.stop()
	$Area2D/MetalCollision.set("disabled", true)
	$BodyCollision.set("disabled", true)
	$AnimatedSprite.visible = false
	.handle_death()

#func _on_area_entered(area):
#	DebugUtils.log("area entered")
#	if area.is_in_group("player"):
#		DebugUtils.log("player hurt")
