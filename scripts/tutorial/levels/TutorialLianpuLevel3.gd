extends "res://scripts/game_play/LianpuNormal/LianpuNormal.gd"


var over_count:=0
var is_over_energy_limit:=false
var back_count:=0

var player_energy:=0

func _ready():
	# 安全初始化
	taiji_mode=GameEnums.TaijiMode.huo
	#该脸谱应该静止
	speed=0
	# 获取所有死亡动画的名称
	for anim in $AnimationPlayer.get_animation_list():
		if anim.begins_with("death_"):
			death_animations.append(anim)
	$AnimatedDeath.visible=false
	show_pass_condition()
	#初始脸谱能量字体大小
	if $EnergyLabel!=null:
		$EnergyLabel.set_scale($EnergyLabel.get_scale()*1.5)
	change_energy_and_operation()

func change_energy_and_operation():
	var	random = RandomNumberGenerator.new()
	random.randomize()
	energy=random.randi_range(1,10)
	
	update_operation_type(taiji_mode)
	update_energy_label()
	#脸谱能量字体跟随太极模式颜色
	init_energy_label_color()

func _on_death_animation_finished():
	#开启碰撞体和图片
	$BodyCollision.set("disabled", false)
	$Sprite.visible=true
	$EnergyLabel.visible=true
	$AnimatedDeath.visible=false
	is_dying=false
	
	if Global.energy>Global.max_energy or Global.energy<Global.min_energy:
		over_count+=1
		is_over_energy_limit=true
	else:
		if is_over_energy_limit:
			back_count+=1
			is_over_energy_limit=false
	check_is_passed_level()
	change_energy_and_operation()
	
func cycle_taiji_mode():
	var index=taiji_order.find(taiji_mode)
	taiji_mode=taiji_order[(index+1)%taiji_order.size()]
	update_operation_type(taiji_mode)
	if sprite != null:
		update_texture()
	else:
		printerr("模式切换失败：Sprite节点丢失")

	change_energy_and_operation()

func check_is_passed_level():
	show_pass_condition()
	if over_count >=4 and back_count >=2:
		if DataMgr.get_setting("tutorial","is_passed_level_3")==false:
			DataMgr.set_setting("tutorial","is_passed_level_3",true)
		$"../PassedLevel".visible=true
	
func show_pass_condition():
	var condition_label=$"../TeachingDisplay".get_node("PassLevelConditionLabel")
	condition_label.set_text("过关条件：\n1.能量超限四次（%d/4）\n2.能量回到限制区间两次（%d/2）" % [over_count,back_count])
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
