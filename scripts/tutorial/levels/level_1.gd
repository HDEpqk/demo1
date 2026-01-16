extends "res://scripts/tutorial/levels/level.gd"


onready var cursor_icon=$TutorialSpotlight/CursorIcon

var taiji_change_count:=0#改变太极状态的次数
onready var condition_label=$TutorialSpotlight/count
var center_position:Vector2

func _ready():
	._ready()
	var node=get_node("TutorialSpotlight/Control")
	if  node!=null:
		center_position=node.rect_position
	else:
		center_position=get_viewport().size/2
	var tween = cursor_icon.get_node("Tween")
	tween.interpolate_property(cursor_icon, "rect_position",
	center_position+Vector2(100,0), center_position-Vector2(100,0), 1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.set_repeat(true)
	tween.start()
	#订阅太极模式变化的事件
	EventBus.connect("global_taiji_mode_changed",self,"_on_global_taiji_mode_changed")
	condition_label.text="过关条件：\n1.切换阴阳（%d/4）" % taiji_change_count
	
func _on_global_taiji_mode_changed(new_value: int,old_value: int=0,is_new_mode:=true):
	taiji_change_count+=1
	condition_label.text="过关条件：\n1.切换阴阳（%d/4）" % taiji_change_count
	var tween = condition_label.get_node("Tween")
	tween.interpolate_property(condition_label, "rect_scale",
	Vector2(1.1, 1.1), Vector2(1, 1), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

	if taiji_change_count>=4:
		$PassedLevel.visible=true


