extends RigidBody2D


onready var animation_player=$AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	AnimationMgr.register_player("LianpuDangerFire",animation_player)

#切换到循环动画
func switch_loop_attack():
	animation_player.play("loop_attack")
