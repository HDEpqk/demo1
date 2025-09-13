# EventBus.gd
extends Node

# 静态变量必须声明在类的最顶层（不能放在函数内部）
var instance = null  # 改用普通成员变量

# 基础事件信号
signal event_triggered(event_name, event_args)

signal global_energy_changed(new_value)
signal global_score_changed(new_value)
signal global_taiji_mode_changed(new_value,old_value,is_new_mode)
signal cycle_lianpu(dic)
signal player_hurt(mode)
signal player_recovery(mode)
signal global_multiple_changed(new_value,isTiming,duration)
signal accelerate_spawn_begin(duration)
signal accelerate_spawn_end(value)
signal decelerate_spawn_begin(duration)
signal decelerate_spawn_end(value)
signal crazy_time_begin(duration)
signal crazy_time_end(value)
signal combo(combo_count,combo_timeout,lianpu_taiji_mode)#连击
signal combo_award(combo_score,combo_count)#连击奖励
signal counter(player_taiji_mode,counter_score)#玩家五行克制脸谱
signal anti_counter(player_taiji_mode,anti_counter_score)#玩家五行被脸谱克制
signal wuxing_generation(lianpu_data)#满足玩家五行生脸谱条件时触发，具体能不能生依靠wuxing_generation_available判断
signal wuxing_generation_available(lianpu_data)#玩家有足够的五行次数去生脸谱
signal anti_wuxing_generation(player_taiji_mode)#玩家五行被脸谱生


signal kill_lianpu_award(base_score)#消灭脸谱奖励分数
signal use_wuxing(player_taiji_mode)#使用五行
signal use_five_elements()#使用五行

signal mu_protect_open(value)#当在木模式开启木保护机制触发的事件
signal mu_protect_close(value)#当关闭木保护机制时触发的事件
signal game_over(info)
#http相关
signal http_fetch_request_completed(result)
signal http_update_request_completed(result)
signal http_create_user_completed(result)
signal http_read_user_id_by_name_completed(result)
signal http_read_user_name_by_id_completed(user_id,username)
signal user_rank_readed(result)
signal network_error(error_msg)#网络出错
signal network_available(result)#网络可用


func _ready():
	instance = self  # 初始化实例引用

# 全局访问方法（取消static修饰符）
func fire_event(event_name, args = null):
	#可用于全局日志记录哪些事件触发了
	call_deferred("emit_signal", "event_triggered", event_name, args)
	if has_signal(event_name):
		call_deferred("emit_signal", event_name, args)

func connect_event(event_name, target, method):
	if has_signal(event_name):
		connect(event_name, target, method)

func fire_event_2param(event_name, arg1,arg2):
	if has_signal(event_name):
		# 使用解包操作符 * 将参数数组展开为单独的参数
		call_deferred("emit_signal", event_name, arg1,arg2)
		DebugUtils.log("arg1="+str(arg1)+"\n"+"arg2="+str(arg2))
		
func fire_event_3param(event_name, arg1,arg2,arg3):
	if has_signal(event_name):
		# 使用解包操作符 * 将参数数组展开为单独的参数
		call_deferred("emit_signal", event_name, arg1,arg2,arg3)
		DebugUtils.log("arg1="+str(arg1)+"\n"+"arg2="+str(arg2)+"arg3="+str(arg3))

func fire_event_4param(event_name, arg1,arg2,arg3,arg4):
	if has_signal(event_name):
		# 使用解包操作符 * 将参数数组展开为单独的参数
		call_deferred("emit_signal", event_name, arg1,arg2,arg3,arg4)
		DebugUtils.log("arg1="+str(arg1)+"\n"+"arg2="+str(arg2)+"arg3="+str(arg3)+"arg4="+str(arg4))
