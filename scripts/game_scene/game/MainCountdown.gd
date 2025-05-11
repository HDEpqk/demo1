extends Node2D  # 假设指针的父节点是场景根节点

export var total_time: int = 300  # 总倒计时秒数

var current_time: int


func _ready():
	current_time = total_time
	$MainCountdownTimer.wait_time = 1.0  # 每秒触发一次
	$MainCountdownTimer.connect("timeout", self, "_on_MainCountdownTimer_timeout")
	if  $"../MainCountdownLabel"== null:
		print("未能找到 CountdownLabel 节点！")
	else:
		print("已成功找到 CountdownLabel 节点。")
	$MainCountdownTimer.start()
	
# 计时器信号回调
func _on_MainCountdownTimer_timeout():
	current_time -= 1
	update_display()
	if current_time <= 0:
		$MainCountdownTimer.stop()
		$"../MainCountdownLabel".text = "TIME UP!"
		# 跳转到结束界面
		get_tree().change_scene("res://scene/GameOverScene.tscn")


# 更新显示（保持缩进统一用4个空格）
func update_display():
	$"../MainCountdownLabel".text = "%d" % current_time
