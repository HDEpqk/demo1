# Global.gd
extends Node

var taiji_mode=GameEnums.TaijiMode.yin
var energy:float=0
var score:float=0
var min_energy:float=-10
var max_energy:float=10
var multiple:int=1
var is_invincible:=false#当前是否是无敌状态

# 在Global.gd或独立配置文件中定义五行相克关系
const WUXING_COUNTER = {
	GameEnums.TaijiMode.huo: GameEnums.TaijiMode.jin,   # 火克金
	GameEnums.TaijiMode.mu: GameEnums.TaijiMode.tu,     # 木克土
	GameEnums.TaijiMode.tu: GameEnums.TaijiMode.shui,   # 土克水
	GameEnums.TaijiMode.shui: GameEnums.TaijiMode.huo,  # 水克火
	GameEnums.TaijiMode.jin: GameEnums.TaijiMode.mu     # 金克木
}

var mode_status={
	GameEnums.TaijiMode.yin:{"isActive":true},
	GameEnums.TaijiMode.yang:{"isActive":true},
	GameEnums.TaijiMode.jin:{"isActive":true},
	GameEnums.TaijiMode.mu:{"isActive":true},
	GameEnums.TaijiMode.shui:{"isActive":true},
	GameEnums.TaijiMode.huo:{"isActive":true},
	GameEnums.TaijiMode.tu:{"isActive":true}
}

func _ready():
	EventBus.connect("global_energy_changed", self, "_on_energy_changed")
	EventBus.connect("global_taiji_mode_changed", self, "_on_taiji_mode_changed")
	EventBus.connect("global_score_changed", self, "_on_score_changed")
	EventBus.connect("global_multiple_changed", self, "_on_multiple_changed")
	#订阅player受伤的事件
	EventBus.connect("player_hurt",self,"_on_player_hurt")
	#订阅player恢复的事件
	EventBus.connect("player_recovery",self,"_on_player_recovery")
	#订阅开始疯狂时间的事件
	EventBus.connect("crazy_time_begin",self,"_on_crazy_time_begin")
	#订阅结束疯狂时间的事件
	EventBus.connect("crazy_time_end",self,"_on_crazy_time_end")
	
func _on_energy_changed(new_value: float):
	energy = new_value
	DebugUtils.log("全局能量已更新："+str(energy))
	
func _on_taiji_mode_changed(new_value:int,old_value:int):
	taiji_mode = new_value
	DebugUtils.log("全局模式已更新,新的值为："+str(taiji_mode)+"旧的值为："+str(old_value))

func _on_score_changed(new_value: float):
	score=new_value
	DebugUtils.log("全局分数已更新："+str(score))

func _on_multiple_changed(new_value: int):
	multiple= clamp(new_value,1,2)
	DebugUtils.log("全局倍数已更新："+str(multiple))

func _on_player_hurt(global_mode):
	DebugUtils.log("玩家受伤时做的事global")
	match global_mode:
		GameEnums.TaijiMode.yin:
			mode_status[GameEnums.TaijiMode.yin]["isActive"]=false
		GameEnums.TaijiMode.yang:
			mode_status[GameEnums.TaijiMode.yang]["isActive"]=false
		GameEnums.TaijiMode.jin:
			mode_status[GameEnums.TaijiMode.jin]["isActive"]=false
		GameEnums.TaijiMode.mu:
			mode_status[GameEnums.TaijiMode.mu]["isActive"]=false
		GameEnums.TaijiMode.shui:
			mode_status[GameEnums.TaijiMode.shui]["isActive"]=false
		GameEnums.TaijiMode.huo:
			mode_status[GameEnums.TaijiMode.huo]["isActive"]=false
		GameEnums.TaijiMode.tu:
			mode_status[GameEnums.TaijiMode.tu]["isActive"]=false

func _on_player_recovery(global_mode):
	DebugUtils.log("玩家恢复时做的事global")
	match global_mode:
		GameEnums.TaijiMode.yin:
			mode_status[GameEnums.TaijiMode.yin]["isActive"]=true
		GameEnums.TaijiMode.yang:
			mode_status[GameEnums.TaijiMode.yang]["isActive"]=true
		GameEnums.TaijiMode.jin:
			mode_status[GameEnums.TaijiMode.jin]["isActive"]=true
		GameEnums.TaijiMode.mu:
			mode_status[GameEnums.TaijiMode.mu]["isActive"]=true
		GameEnums.TaijiMode.shui:
			mode_status[GameEnums.TaijiMode.shui]["isActive"]=true
		GameEnums.TaijiMode.huo:
			mode_status[GameEnums.TaijiMode.huo]["isActive"]=true
		GameEnums.TaijiMode.tu:
			mode_status[GameEnums.TaijiMode.tu]["isActive"]=true

func _on_crazy_time_begin(duration):
	DebugUtils.log("_on_crazy_time_begin: Global")
	is_invincible=true

func _on_crazy_time_end(value):
	DebugUtils.log("_on_crazy_time_end: Global")
	is_invincible=false

func reset_data():
	taiji_mode=GameEnums.TaijiMode.yin
	energy=0
	score=0
	min_energy=-10
	max_energy=10


