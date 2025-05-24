# EventBus.gd
extends Node

# 静态变量必须声明在类的最顶层（不能放在函数内部）
var instance = null  # 改用普通成员变量

# 基础事件信号
signal event_triggered(event_name, event_args)

signal global_energy_changed(new_value)
signal global_score_changed(new_value)
signal global_taiji_mode_changed(new_value,old_value)
signal cycle_lianpu(dic)
signal player_hurt(mode)
signal player_recovery(mode)
signal global_multiple_changed(new_value)
signal accelerate_spawn_begin(duration)
signal accelerate_spawn_end(value)
signal decelerate_spawn_begin(duration)
signal decelerate_spawn_end(value)
signal crazy_time_begin(duration)
signal crazy_time_end(value)


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

func fire_event_multiparameter(event_name, arg1,arg2):
	if has_signal(event_name):
		# 使用解包操作符 * 将参数数组展开为单独的参数
		call_deferred("emit_signal", event_name, arg1,arg2)
		DebugUtils.log("arg1="+str(arg1)+"\n"+"arg2="+str(arg2))
