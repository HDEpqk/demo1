extends "res://scripts/game_play/Lianpu.gd"

func _ready():
	._ready()
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
func cycle_taiji_mode():
	pass
