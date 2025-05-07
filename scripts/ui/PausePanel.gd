extends "res://scripts/ui/UIBasePanel.gd"

# 回到开始场景按钮
var back_to_start_button
# 返回游戏按钮
var resume_game_button


func init_panel():
	#初始隐藏面板
	UiMgr.hide_control("PausePanel")
	# 获取按钮节点
	back_to_start_button = get_node("CenterContainer/VBoxContainer/BackToStartButton")
	resume_game_button = get_node("CenterContainer/VBoxContainer/ResumeGameButton")

	
	# 连接按钮信号
	back_to_start_button.connect("pressed", self, "_on_BackToStartButton_pressed")
	resume_game_button.connect("pressed", self, "_on_ResumeGameButton_pressed")



func _on_BackToStartButton_pressed():
	UiMgr.hide_control("PausePanel")
	get_tree().change_scene("res://scene/game_scene/start/StartScene.tscn")

func _on_ResumeGameButton_pressed():
	UiMgr.hide_control("PausePanel")
	
func _on_PausePanel_visibility_changed():
	get_tree().paused=visible

