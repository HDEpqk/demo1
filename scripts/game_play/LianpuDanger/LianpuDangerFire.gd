# LianpuDangerFire.gd
extends "res://scripts/game_play/LianpuDanger/LianpuDanger.gd"

export var rotation_speed := 2.0  # 每秒旋转角度（可编辑器调整）


func _physics_process(delta):
	._physics_process(delta)
	# 设置角速度 (旋转)
	angular_velocity = rotation_speed


	
#切换到循环动画
func switch_loop_attack():
	$AnimationPlayer.play("loop_attack")
	
func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set("disabled", true)
	$Area2D/FireCollision.set("disabled", true)
	$AnimatedSprite.visible=false
	.handle_death()


