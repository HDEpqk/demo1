# LianpuDanger.gd（基类）
extends "res://scripts/game_play/Lianpu.gd"

func _ready():
	._ready()
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)

func cycle_taiji_mode():
	# 自动获取类型名称（如"danger_fire"）
	var type_name = self.filename.get_file().trim_suffix(".tscn").to_lower()
	DebugUtils.log(" 自动获取类型名称:"+type_name)
	EventBus.fire_event("cycle_lianpu", {
		"current_type": type_name,
		"position": global_position,
		"origin_node": self  # 直接传递节点引用
	})

	
