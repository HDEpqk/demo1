extends Node2D

onready var lianpu_start_scene=$LianpuStartScene
onready var lianpu_user_register=$LianpuUserRegister
onready var center = $Center
onready var viewport_size = get_viewport().size
onready var user_register=$UserRegister


func _ready():
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
	if !check_nick_name_exist():
		#如果玩家本地昵称不存在就打开用户注册界面
		user_register.visible=true
		
	
func check_nick_name_exist() ->bool:
	#检查玩家本地昵称是否存在
	var nick_name=DataMgr.get_setting("user","nick_name")
	if nick_name.empty():return false
	else:return true




