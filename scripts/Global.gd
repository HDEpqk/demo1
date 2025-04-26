# Global.gd
extends Node


var is_yang_mode:=false
var energy:float=0
var min_energy:float=-10
var max_energy:float=10
var	random = RandomNumberGenerator.new()
var ui = null


func _ready():
	random.randomize()
	# 尝试直接获取目标节点
	var tree = get_tree()
	var current_scene = tree.get_current_scene()
	ui = current_scene.get_node("UI")  # 根据实际节点路径修改
	if ui:
		print("单例脚本直接获取到新场景节点")
	else:
		# 若未获取到，再监听 node_added 信号
		tree.connect("node_added", self, "_on_node_added")


func _on_node_added(node):
	if node.name == "UI": # 根据实际节点名称修改
		ui = node
		print("单例脚本获取到新场景节点")
		
func reset_data():
	is_yang_mode=false
	energy=0
	min_energy=-10
	max_energy=10
