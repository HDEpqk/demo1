extends CanvasLayer

onready var panel=$Panel
onready var video_player=$Panel/VideoPlayer
onready var rich_label=$Panel/RichTextLabel
onready var left_btn=$Panel/LeftTextureButton
onready var right_btn=$Panel/RightTextureButton

onready var passed_level_panel=$PassedLevelPanel

var current_page:=0
var total_page:=0
var video_list:=[]


func _ready():
	rich_label.bbcode_enabled=true
	panel.hide()





func _on_CloseTextureButton_pressed():
	panel.hide()


func _on_Panel_visibility_changed():
	get_tree().paused=panel.visible


func _on_LeftTextureButton_pressed():
	current_page-=1
	change_page(current_page)
	right_btn.disabled=false
	right_btn.visible=true
	if current_page>=0:
		left_btn.disabled=true
		left_btn.visible=false


func _on_RightTextureButton_pressed():
	current_page+=1
	change_page(current_page)
	left_btn.disabled=false
	left_btn.visible=true
	if current_page>=total_page-1:
		right_btn.disabled=true
		right_btn.visible=false

func change_page(page_index:int):
	#过场动画
	
	video_player.stream=video_list[page_index]["video"]
	video_player.play()
	rich_label.bbcode_text=video_list[page_index]["text"]
	
	
func init_video(list:Array):
	video_list=list
	total_page=video_list.size()
	left_btn.disabled=true
	left_btn.visible=false
	if total_page<=1:
		right_btn.disabled=true
		right_btn.visible=false
	change_page(current_page)



