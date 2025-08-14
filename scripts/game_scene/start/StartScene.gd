extends Node2D

onready var lianpu_start_scene=$LianpuStartScene
onready var lianpu_user_register=$LianpuUserRegister
onready var center = $Center
onready var viewport_size = get_viewport().size
onready var user_register=$UserRegister
onready var isSfxOn:bool=DataMgr.get_setting("audio","sound_enabled")

func _ready():
	if isSfxOn:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)#取消静音
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)#静音
	#游戏每天第一次启动就记录一下时间戳
	DataMgr.first_set_upload_timestamp()
	lianpu_user_register.visible=false
	user_register.visible=false
	#设置背景的缩放
	var texture_size = $BG.get_size()
	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	$BG.rect_scale = Vector2(scale_x, scale_y)
	#设置场景脸谱的位置
	lianpu_start_scene.position=viewport_size/2
	#设置center的位置
	center.position.x = viewport_size.x/2
	center.position.y = viewport_size.y/2+130
	#设置lianpu_user_register位置
	lianpu_user_register.position.x = viewport_size.x/2
	lianpu_user_register.position.y = viewport_size.y/2+280
	
	user_register.rect_position=viewport_size/2
	
	#EventBus.connect("network_available",self,"_on_network_available")
	EventBus.connect("http_read_user_id_by_name_completed",self,"_on_http_read_user_id_by_name_completed")
	#如果玩家没注册，开始界面显示注册lianpu，只在玩家确认注册才去判断网络状况
	if DataMgr.get_setting("user","nick_name").empty():
		lianpu_user_register.visible=true
	else:
		lianpu_user_register.queue_free()
		user_register.queue_free()

#func _on_network_available(error_msg):
#	if !check_nick_name_exist():
#		#如果玩家本地昵称不存在并且网络没问题就自动打开用户注册界面
#		user_register.visible=true

func _on_http_read_user_id_by_name_completed(result):
	lianpu_user_register.queue_free()






