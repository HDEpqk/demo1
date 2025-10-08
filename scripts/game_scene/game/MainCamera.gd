extends Node2D

onready var main_camera=$MainCamera
onready var ui=$"../UI"
# 抖动参数
var current_time=0#当前时间
#export var time_length=1 #总时间
#export var time_add=0.05#时间累加值
#export var shake_range=10#抖动范围
#export var shake_freq=0.05#抖动频率
#
##受伤抖动相关
#onready var recovery_speed:=16#抖动后的恢复速度
#onready var shake_strength:=0#抖动强度
var camera_origin_pos
var ui_origin_offset

func _ready():
	#绑定游戏结束事件
	EventBus.connect_event("game_over",self,"_on_game_over")
	#订阅player受伤的事件
	EventBus.connect("player_hurt",self,"_on_player_hurt")
	#订阅克制事件
	EventBus.connect("counter",self,"_on_counter")
	camera_origin_pos=main_camera.get_position()
	ui_origin_offset=ui.get_offset()
#	DebugUtils.log("camera_origin_pos:"+str(camera_origin_pos))
#	DebugUtils.log("ui_origin_offset:"+str(ui_origin_offset))
func _on_player_hurt(global_mode):
	start_shake(0.2,0.05,10,0.05)

func _on_game_over(info):
	start_shake(1,0.05,20,0.05)

func _on_counter(player_taiji_mode,counter_score):
	start_shake(0.2,0.05,10,0.02)

# 摄像机的抖动效果
func start_shake(time_length,time_add,shake_range,shake_freq):
	#DebugUtils.log("摄像机和UI开始抖动")
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
#	DebugUtils.log("main_camera_position:"+str(main_camera.get_position()))
#	DebugUtils.log("ui_offset:"+str(ui.get_offset()))



