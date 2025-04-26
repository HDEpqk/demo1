extends Control



# 回到开始场景按钮
var back_to_start_button
# 返回游戏按钮
var resume_game_button


func _ready():
	#初始隐藏面板
	hide_panel()
	# 获取按钮节点
	back_to_start_button = get_node("CenterContainer/VBoxContainer/BackToStartButton")
	resume_game_button = get_node("CenterContainer/VBoxContainer/ResumeGameButton")

	# 连接按钮信号
	back_to_start_button.connect("pressed", self, "_on_BackToStartButton_pressed")
	resume_game_button.connect("pressed", self, "_on_ResumeGameButton_pressed")



func show_panel():
	show()
func hide_panel():
	hide()

func _on_BackToStartButton_pressed():
	hide_panel()
	get_tree().change_scene("res://scene/StartScene.tscn")

func _on_ResumeGameButton_pressed():
	hide_panel()
	


func _on_PausePanel_visibility_changed():
	get_tree().paused=visible
