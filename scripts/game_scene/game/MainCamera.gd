extends Node2D

onready var main_camera=$MainCamera
onready var ui=$"../UI"
# 抖动参数
var current_time=0#当前时间
export var time_length=1 #总时间
export var time_add=0.05#时间累加值
export var shake_range=10#抖动范围
export var shake_freq=0.05#抖动频率



func _ready():
	#绑定游戏结束事件
	EventBus.connect_event("game_over",self,"_on_game_over")

func _on_game_over(info):
	DebugUtils.log("_on_game_over:MainCamera")
	# 1. 播放抖动效果
	start_shake()

# 摄像机抖动效果
func start_shake():
	DebugUtils.log("摄像机和UI开始抖动")
	var camera_origin_pos=main_camera.get_position()
	var ui_origin_offset=ui.get_offset()
	while current_time<time_length:
		current_time+=time_add
		var offset=Vector2(rand_range(-shake_range,shake_range),rand_range(-shake_range,shake_range))
		var newpos=camera_origin_pos
		newpos+=offset
		main_camera.set_position(newpos)
		ui.set_offset(offset)
		yield(get_tree().create_timer(shake_freq),"timeout")
	current_time=0
	main_camera.set_position(camera_origin_pos)
	ui.set_offset(ui_origin_offset)




