extends "res://scripts/game_play/LianpuNormal/LianpuNormal.gd"


var yin_count:=0
var yang_count:=0

func _ready():
	# 安全初始化
	taiji_mode=GameEnums.TaijiMode.huo
	energy=1#赋值成1避免除以0
	#该脸谱应该静止
	speed=0
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	$AnimatedDeath.visible=false
	show_pass_condition()




func _on_death_animation_finished():
	#开启碰撞体和图片
	$BodyCollision.set("disabled", false)
	$Sprite.visible=true
	$AnimatedDeath.visible=false
	is_dying=false
	
	
	yin_count+=1
	
	check_is_passed_level()


func cycle_taiji_mode():
	var index=taiji_order.find(taiji_mode)
	taiji_mode=taiji_order[(index+1)%taiji_order.size()]
	update_operation_type(taiji_mode)
	if sprite != null:
		update_texture()
	else:
		printerr("模式切换失败：Sprite节点丢失")

	yang_count+=1

	check_is_passed_level()


func check_is_passed_level():
	show_pass_condition()
	if yin_count >=4 and yang_count >=4:
		if DataMgr.get_setting("tutorial","is_passed_level_2")==false:
			DataMgr.set_setting("tutorial","is_passed_level_2",true)
		$"../PassedLevel".visible=true
	

func show_pass_condition():
	var condition_label=$"../TeachingDisplay".get_node("PassLevelConditionLabel")
	condition_label.set_text("过关条件：\n1.用阴状态消灭脸谱（%d/4）\n2.用阳状态切换脸谱（%d/4）" % [yin_count,yang_count])
	var tween = condition_label.get_node("Tween")
	tween.interpolate_property(condition_label, "rect_scale",
	Vector2(1.1, 1.1), Vector2(1, 1), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
func update_texture():
	# 根据太极模式加载对应贴图
	match taiji_mode:
		GameEnums.TaijiMode.huo:
			sprite.texture=load("res://art/lianpu/LianpuNormal/red_shadow_64.png")
		GameEnums.TaijiMode.jin:
			sprite.texture=load("res://art/lianpu/LianpuNormal/yellow_shadow_64.png")
		GameEnums.TaijiMode.mu:
			sprite.texture=load("res://art/lianpu/LianpuNormal/green_shadow_64.png")
		GameEnums.TaijiMode.shui:
			sprite.texture=load("res://art/lianpu/LianpuNormal/blue_shadow_64.png")
