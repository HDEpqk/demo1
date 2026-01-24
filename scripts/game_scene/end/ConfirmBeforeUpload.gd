extends Control

const SELECT_SFX=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Select - 1.mp3str")
const CURSOR_CLICK_1=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Cursor - 1.mp3str")
onready var popup_dialog=$"../PopupDialog"
onready var popup_dialog_label=$"../PopupDialog/Label"
onready var popup_dialog_icon=$"../PopupDialog/Icon"
func _ready():
	self.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ConfirmButton_pressed():
	self.hide()
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_1
	$AudioStreamPlayer.play()
	#判断当前模式是否能上传分数
	if SceneMgr.game_scene_name=="LimitedGame":
		if DataMgr.is_limited_upload_valid():
			DataMgr.update_leaderboarder_player(DataMgr.LIMITED_BOARDER)
		else:
			popup_dialog_icon.set_visible(true)
			popup_dialog_label.self_modulate=Color("#F4606C")
			popup_dialog_label.text="今日限时排行榜上传次数已耗光"
			popup_dialog.popup()
	elif SceneMgr.game_scene_name=="EndlessGame":
		if DataMgr.is_endless_upload_valid():
			DataMgr.update_leaderboarder_player(DataMgr.ENDLESS_BOARDER)
		else:
			popup_dialog_icon.set_visible(true)
			popup_dialog_label.self_modulate=Color("#F4606C")
			popup_dialog_label.text="今日无尽排行榜上传次数已耗光"
			popup_dialog.popup()


func _on_CancelButton_pressed():
	self.hide()
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_1
	$AudioStreamPlayer.play()
func _on_ConfirmButton_mouse_entered():
	#播放音效
	$AudioStreamPlayer.stream=SELECT_SFX
	$AudioStreamPlayer.play()
func _on_CancelButton_mouse_entered():
	#播放音效
	$AudioStreamPlayer.stream=SELECT_SFX
	$AudioStreamPlayer.play()


func _on_ConfirmBeforeUpload_visibility_changed():
	get_tree().paused=self.visible
