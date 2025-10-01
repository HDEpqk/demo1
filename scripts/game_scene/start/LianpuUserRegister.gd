extends "res://scripts/game_play/Lianpu.gd"

onready var return_sprite=$Sprite
onready var return_label=$SelectionLabel

func _ready():
	# 安全初始化taiji_mode
	taiji_mode=GameEnums.TaijiMode.yin
	# 安全初始化图片
	if return_sprite!= null:
		return_sprite.texture=load("res://art/ui/setting/lianpu_register.png")
	else:
		printerr("return_sprite为空")
	#该脸谱应该静止
	speed=0
	if return_label!= null:
		if DataMgr.get_setting("user","nick_name").empty():
			return_label.text="注册用户"
		else:
			#昵称不为空说明用户已注册，销毁自身
			queue_free()
	else:
		printerr("return_label为空")
	if $AnimationPlayer!=null:
		#获取所有死亡动画的名称
		for anim in $AnimationPlayer.get_animation_list():
			if anim.begins_with("death_"):
				death_animations.append(anim)
	$AnimatedDeath.visible=false#关闭AnimatedDeath
	#关闭开启和图片
	$BodyCollision.set("disabled", false)
	$Sprite.visible=true
	$SelectionLabel.self_modulate=Color.black
	$SelectionLabel.visible=true
	



func cycle_taiji_mode():
	pass


func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set("disabled", true)
	$Sprite.visible=false
	$SelectionLabel.visible=false
	if is_dying:return#如果正在死亡则退出避免重复调用
	is_dying=true
	# 切换到死亡层（Player 不检测此层）
	if has_node("Area2D"):
		$Area2D.set_collision_layer(1 << LAYER_DEAD)  # 设置层
		$Area2D.set_collision_mask(0)  # 设置掩码，不检测任何层
	#根据taiji_mode改变死亡动画的颜色
	$AnimatedDeath.self_modulate=Color.black
	
	$AnimatedDeath.visible=true#打开AnimatedDeath
	if $EnergyLabel!=null:
		$EnergyLabel.visible=false#关闭EnergyLabel
	#随机播放死亡动画
	if death_animations.size() > 0:
		# 随机选择一个死亡动画
		var random_index = randi() % death_animations.size()
		var random_animation:String = death_animations[random_index]

		#播放随机选择的动画
		$AnimationPlayer.play(random_animation)
	else:
		print("No death animations found.")
	
	handle_element_counter_sfx()#播放死亡音效

func _on_death_animation_finished():
	#打开用户上榜注册
	$"../CanvasLayer/UserRegister".visible=true
	#隐藏其他界面
#	$"../CanvasLayer/OperationTipLabel".visible=false
#	$"../LianpuStartScene".visible=false
#	$"../CanvasLayer/TutorialControl".visible=false
#	$"../Center".visible=false
#	self.visible=false
	#开启碰撞体和图片
	$BodyCollision.set("disabled", false)
	$Sprite.visible=true
	$SelectionLabel.visible=true
	$AnimatedDeath.visible=false
	is_dying=false



