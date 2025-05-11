# Global.gd
extends Node

var taiji_mode=GameEnums.TaijiMode.yin
var energy:float=0
var score:float=0
var min_energy:float=-10
var max_energy:float=10

# 在Global.gd或独立配置文件中定义五行相克关系
const WUXING_COUNTER = {
	GameEnums.TaijiMode.huo: GameEnums.TaijiMode.jin,   # 火克金
	GameEnums.TaijiMode.mu: GameEnums.TaijiMode.tu,     # 木克土
	GameEnums.TaijiMode.tu: GameEnums.TaijiMode.shui,   # 土克水
	GameEnums.TaijiMode.shui: GameEnums.TaijiMode.huo,  # 水克火
	GameEnums.TaijiMode.jin: GameEnums.TaijiMode.mu     # 金克木
}

func _ready():
	EventBus.connect("global_energy_changed", self, "_on_energy_changed")
	EventBus.connect("global_taiji_mode_changed", self, "_on_taiji_mode_changed")
	EventBus.connect("global_score_changed", self, "_on_score_changed")
	

func _on_energy_changed(new_value: float):
	energy = new_value
	#DebugUtils.log("全局能量已更新："+str(energy))
	
func _on_taiji_mode_changed(new_value:int):
	taiji_mode = new_value
	#print("全局模式已更新：",taiji_mode)

func _on_score_changed(new_value: float):
	score= new_value
	DebugUtils.log("全局分数已更新："+str(score))

func reset_data():
	taiji_mode=GameEnums.TaijiMode.yin
	energy=0
	score=0
	min_energy=-10
	max_energy=10


