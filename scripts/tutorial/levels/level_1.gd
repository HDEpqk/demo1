extends "res://scripts/tutorial/levels/level.gd"


# 在新手教程管理器中
onready var spotlight = $TutorialSpotlight  # 聚光灯节点路径
onready var rich_label=$TutorialSpotlight/RichTextLabel
onready var cursor_icon=$TutorialSpotlight/CursorIcon

var taiji_change_count:=0#改变太极状态的次数


func _ready():
	var tween = cursor_icon.get_node("Tween")
	tween.interpolate_property(cursor_icon, "rect_position",
	Vector2(800, get_viewport().size.y/2), Vector2(400, get_viewport().size.y/2), 1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.set_repeat(true)
	tween.start()
	#订阅太极模式变化的事件
	EventBus.connect("global_taiji_mode_changed",self,"_on_global_taiji_mode_changed")

func _on_global_taiji_mode_changed(new_value: int,old_value: int=0,is_new_mode:=true):
	taiji_change_count+=1
	$TutorialSpotlight/count.text="过关条件：切换阴阳4次（%d/4）" % taiji_change_count
	if taiji_change_count>=4:
		$PassedLevel.visible=true


