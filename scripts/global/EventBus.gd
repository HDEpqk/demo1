# EventBus.gd
extends Node

# 静态变量必须声明在类的最顶层（不能放在函数内部）
var instance = null  # 改用普通成员变量

# 基础事件信号
signal event_triggered(event_name, event_args)
signal score_changed(new_score)
signal player_died(position)
signal enemy_spawned(enemy_type)
signal global_energy_changed(new_value)
signal global_score_changed(new_value)
signal global_taiji_mode_changed(new_value)
signal cycle_lianpu(dic)

func _ready():
	instance = self  # 初始化实例引用

# 全局访问方法（取消static修饰符）
func fire_event(event_name, args = null):
	call_deferred("emit_signal", "event_triggered", event_name, args)
	call_deferred("emit_signal", event_name, args)

func connect_event(event_name, target, method):
	if has_signal(event_name):
		connect(event_name, target, method)
