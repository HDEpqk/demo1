extends Node2D

const LOCK_ICON=preload("res://art/tutorial/lock_64.png")
const LEVEL_ICON=preload("res://art/tutorial/level_icon.png")
#sfx
const SELECT_SFX=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Select - 1.mp3str")
const CURSOR_CLICK_1=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Cursor - 1.mp3str")

onready var viewport_size = get_viewport().size
onready var level_list:=[]
onready var turotiral_back_main_btn=$CanvasLayer/TutorialBackMainBtn


func _ready():
	#设置背景的缩放
	var texture_size = $BG.get_size()
	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	$BG.rect_scale = Vector2(scale_x, scale_y)
	#DataMgr.set_setting("tutorial","is_passed_level_2",true)
	#取消暂停
	get_tree().paused=false

	level_list=$CanvasLayer/GridContainer.get_children()
	for i in range(level_list.size()):
		if DataMgr.get_setting("tutorial","is_passed_level_%d"% (i+1))==true:
			level_list[i].set_button_icon(LEVEL_ICON)
			level_list[i].get_node("LevelIndex").set_text(str(i+1))
			level_list[i].disabled=false
			level_list[i].connect("button_down",self,"_on_button_down",[i])
			level_list[i].connect("button_up",self,"_on_button_up",[i])
			level_list[i].connect("mouse_entered",self,"_on_mouse_entered",[i])
			level_list[i].connect("mouse_exited",self,"_on_mouse_exited",[i])
			level_list[i].connect("pressed",self,"_on_button_pressed",[i])
		else:
			level_list[i].set_button_icon(LOCK_ICON)
			level_list[i].get_node("LevelIndex").set_text("")
			level_list[i].disabled=true
		


func _on_button_pressed(i):
	SceneMgr.change_scene("res://scene/tutorial/levels/level_%d.tscn" % (i+1))


func _on_button_down(i):
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_1
	$AudioStreamPlayer.play()
	#按下btn时候把btn变小
	level_list[i].rect_scale=Vector2(1,1)

func _on_button_up(i):
	#松开btn时候把btn变大
	level_list[i].rect_scale=Vector2(1.1,1.1)

func _on_mouse_entered(i):
	#鼠标进入让btn变大
	level_list[i].rect_scale=Vector2(1.1,1.1)
	#播放音效
	$AudioStreamPlayer.stream=SELECT_SFX
	$AudioStreamPlayer.play()

func _on_mouse_exited(i):
	#鼠标离开让btn变小
	level_list[i].rect_scale=Vector2(1,1)








func _on_TutorialBackMainBtn_button_down():
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_1
	$AudioStreamPlayer.play()
	turotiral_back_main_btn.rect_scale=Vector2(1,1)


func _on_TutorialBackMainBtn_button_up():
	turotiral_back_main_btn.rect_scale=Vector2(1.1,1.1)


func _on_TutorialBackMainBtn_pressed():
	SceneMgr.change_scene("res://scene/game_scene/start/StartScene.tscn")


func _on_TutorialBackMainBtn_mouse_entered():
	turotiral_back_main_btn.rect_scale=Vector2(1.1,1.1)
	#播放音效
	$AudioStreamPlayer.stream=SELECT_SFX
	$AudioStreamPlayer.play()

func _on_TutorialBackMainBtn_mouse_exited():
	turotiral_back_main_btn.rect_scale=Vector2(1,1)
