# LianpuDanger.gd（基类）
extends "res://scripts/game_play/Lianpu.gd"

func _ready():
	._ready()
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)	
	#设置对象属于第2层
	collision_layer =1<<1
	# 设置对象检测第1层和第4层
	collision_mask = 1 | (1 << 3)
	
func init(_mode:int, pos:Vector2, _reward_score:float, _speed:float):
	.init(_mode, pos, _reward_score, _speed)
	#初始能量值
	var	random = RandomNumberGenerator.new()
	random.randomize()
	energy=random.randi_range(0,10)
	DebugUtils.log("初始能量："+str(energy))
	update_energy_label()
