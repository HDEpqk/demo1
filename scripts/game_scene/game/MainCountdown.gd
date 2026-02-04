extends Node2D  # 假设指针的父节点是场景根节点

export var total_time: int = 300  # 总倒计时秒数

var current_time: int
onready var main_countdown_timer=$MainCountdownTimer
onready var main_countdown_label=$"../MainCountdownLabel"

func _ready():
	current_time = total_time
	main_countdown_timer.wait_time = 1.0  # 每秒触发一次
	main_countdown_timer.connect("timeout", self, "_on_MainCountdownTimer_timeout")
	main_countdown_timer.start()
	
# 计时器信号回调
func _on_MainCountdownTimer_timeout():
	current_time -= 1
	update_display()
	if current_time <= 0:
		main_countdown_timer.stop()
		main_countdown_label.text = ""
		#触发游戏结束事件
		EventBus.fire_event("game_over","总时间结束了┗|｀O′|┛ 嗷~~!")


# 更新显示
func update_display():
	main_countdown_label.text = "%d" % current_time
