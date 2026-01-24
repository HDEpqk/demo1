extends Node2D

onready var lianpu_start_scene=$CanvasLayer/VBoxContainer/Control/LianpuStartScene
onready var lianpu_user_register=$CanvasLayer/VBoxContainer/Control3/LianpuUserRegister
onready var center = $CanvasLayer/VBoxContainer/Control2/Center
onready var viewport_size = GuiAutoload.viewport_size
onready var user_register=$CanvasLayer/UserRegister
onready var isSfxOn:bool=true
onready var is_first_tutorial:bool=true

func _ready():
	user_register.visible=false
	#如果玩家没注册，开始界面显示注册lianpu，只在玩家确认注册才去判断网络状况
	if DataMgr.get_setting("user","nick_name").empty():
		lianpu_user_register.visible=true
	else:
		lianpu_user_register.queue_free()
		user_register.queue_free()
		lianpu_start_scene.visible=true
		center.visible=true
	
	isSfxOn=DataMgr.get_setting("audio","sound_enabled")
	if isSfxOn:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)#取消静音
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)#静音
	#游戏每天第一次启动就记录一下时间戳
	#DataMgr.first_set_upload_timestamp()

	EventBus.connect("http_read_user_id_by_name_completed",self,"_on_http_read_user_id_by_name_completed")


#func _on_network_available(error_msg):
#	if !check_nick_name_exist():
#		#如果玩家本地昵称不存在并且网络没问题就自动打开用户注册界面
#		user_register.visible=true

func _on_http_read_user_id_by_name_completed(result):
	lianpu_user_register.queue_free()

func _enter_tree():
	EventBus.fire_event_2param("global_taiji_mode_changed",Global.taiji_mode,Global.taiji_mode)






