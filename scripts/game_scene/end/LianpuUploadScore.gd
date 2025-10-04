extends "res://scripts/game_play/Lianpu.gd"

onready var return_sprite=$Sprite
onready var return_label=$SelectionLabel
onready var confirm_register=$"../CanvasLayer/ConfirmRegister"
onready var user_register=$"../CanvasLayer/UserRegister"
onready var popup_dialog=$"../CanvasLayer/PopupDialog"
onready var popup_dialog_label=$"../CanvasLayer/PopupDialog/Label"
onready var popup_dialog_icon=$"../CanvasLayer/PopupDialog/Icon"
onready var confirm_before_upload=$"../CanvasLayer/ConfirmBeforeUpload"
onready var viewport_size=get_viewport().size

func _ready():
	#检查是否需要重置upload次数
	DataMgr.check_is_reset_upload_count()
	# 安全初始化taiji_mode
	taiji_mode=GameEnums.TaijiMode.yin
	# 安全初始化图片
	if return_sprite!= null:
		return_sprite.texture=load("res://art/ui/setting/lianpu_upload.png")
	else:
		printerr("return_sprite为空")
	#该脸谱应该静止
	speed=0
	if return_label!= null:
		if SceneMgr.game_scene_name=="LimitedGame":
			return_label.text="上传分数"+"(%d/%d)" \
			% [DataMgr.get_setting("user","limited_upload_current_count"),DataMgr.LIMITED_UPLOAD_TATOL_COUNT]
		elif SceneMgr.game_scene_name=="EndlessGame":
			return_label.text="上传分数"+"(%d/%d)" \
			% [DataMgr.get_setting("user","endless_upload_current_count"),DataMgr.ENDLESS_UPLOAD_TATOL_COUNT]
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
	
	#注册"http_update_request_completed"事件
	EventBus.connect("http_update_request_completed",self,"_on_http_update_request_completed")
	



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
	#判断玩家是否注册过
	if DataMgr.get_setting("user","nick_name").empty():
		#弹出一个对话框提示玩家是否需要注册
		#设置确认注册对话框的位置
		confirm_register.rect_position=viewport_size/2
		confirm_register.show()
	else:
		confirm_before_upload.rect_position=viewport_size/2
		confirm_before_upload.show()
		
	#开启碰撞体和图片
	$BodyCollision.set("disabled", false)
	$Sprite.visible=true
	$SelectionLabel.visible=true
	$AnimatedDeath.visible=false
	is_dying=false


func _on_http_update_request_completed(score):
	if SceneMgr.game_scene_name=="LimitedGame":
		var src_count=DataMgr.get_setting("user","limited_upload_current_count")
		var new_count=src_count-1
		DataMgr.set_setting("user","limited_upload_current_count",new_count)
		return_label.text="上传分数"+"(%d/%d)" \
		% [DataMgr.get_setting("user","limited_upload_current_count"),DataMgr.LIMITED_UPLOAD_TATOL_COUNT]
		DataMgr.set_setting("user","upload_limited_score",score)
	elif SceneMgr.game_scene_name=="EndlessGame":
		var src_count=DataMgr.get_setting("user","endless_upload_current_count")
		var new_count=src_count-1
		DataMgr.set_setting("user","endless_upload_current_count",new_count)
		return_label.text="上传分数"+"(%d/%d)" \
		% [DataMgr.get_setting("user","endless_upload_current_count"),DataMgr.ENDLESS_UPLOAD_TATOL_COUNT]
		DataMgr.set_setting("user","upload_endless_score",score)
	#提示玩家操作成功
	popup_dialog_icon.set_visible(false)
	popup_dialog_label.self_modulate=Color("#19CAAD")
	popup_dialog_label.text="成功上传分数"
	popup_dialog.popup()




