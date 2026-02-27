extends CanvasLayer
const CURSOR_CLICK_2=preload("res://audio/ui/JDSherbert - Ultimate UI SFX Pack - Cursor - 2.mp3str")
onready var panel=$Panel
onready var video_player=$Panel/VideoPlayer
onready var rich_label=$Panel/RichTextLabel
onready var left_btn=$Panel/LeftTextureButton
onready var right_btn=$Panel/RightTextureButton
onready var passed_level_panel=$PassedLevelPanel
#var load_thread: Thread  # 异步加载线程
#onready var loading_panel=$Panel/loading
var current_page:=0
var total_page:=0
var video_list:=[]


func _ready():
	panel.hide()
	self.show()
	#loading_panel.hide()

func init_video(list:Array):
	video_list=list
	total_page=video_list.size()
	left_btn.disabled=true
	left_btn.visible=false
	if total_page<=1:
		right_btn.disabled=true
		right_btn.visible=false

func _on_CloseTextureButton_pressed():
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_2
	$AudioStreamPlayer.play()
	#停止正在播放的视频
	if video_player.is_playing():
		video_player.stop()
		print("is_video_playing:"+str(video_player.is_playing()))
	panel.hide()

func _on_Panel_visibility_changed():
	var is_panel_visible=panel.visible
	get_tree().paused=is_panel_visible
	if is_panel_visible:
		change_page(current_page)


func _on_LeftTextureButton_pressed():
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_2
	$AudioStreamPlayer.play()
	current_page-=1
	change_page(current_page)
	right_btn.disabled=false
	right_btn.visible=true
	if current_page<=0:
		left_btn.disabled=true
		left_btn.visible=false


func _on_RightTextureButton_pressed():
	#播放音效
	$AudioStreamPlayer.stream=CURSOR_CLICK_2
	$AudioStreamPlayer.play()
	current_page+=1
	change_page(current_page)
	left_btn.disabled=false
	left_btn.visible=true
	if current_page>=total_page-1:
		right_btn.disabled=true
		right_btn.visible=false

#同步加载
func change_page(page_index:int):
#	if video_player.is_playing():
	video_player.stop()
	video_player.set_stream(video_list[page_index]["video"])
	video_player.play()
	rich_label.bbcode_text=video_list[page_index]["text"]
	#print("is_video_playing:"+str(video_player.is_playing()))

#异步加载#
#func change_page(page_index:int):
#	# 1. 停止当前播放的视频
#	if video_player.is_playing():
#		video_player.stop()
#
#	# 2. 显示加载面板
#	_on_video_loading()
#
#	# 3. 如果有正在运行的加载线程，先停止
#	if load_thread and load_thread.is_active():
#		load_thread.wait_to_finish()
#
#	# 4. 记录当前要加载的索引，启动异步加载线程
#	current_page = page_index
#	load_thread = Thread.new()
#	# 将耗时的加载操作放到子线程中执行
#	load_thread.start(self, "_async_load_video", page_index)
#
## 异步加载视频的函数（子线程中执行）
#func _async_load_video(page_index:int):
#	var video_stream = video_list[page_index]["video"]
#	# 更新文本内容
#	rich_label.bbcode_text = video_list[page_index]["text"]
#	# 加载完成后，通过信号通知主线程更新
#	call_deferred("_on_video_loaded", page_index, video_stream)
#
#func _on_video_loading():
#	#执行加载中的效果
#	loading_panel.show()
#	video_player.hide()
#	rich_label.hide()
#	left_btn.disabled=true
#	right_btn.disabled=true
#
#
## 视频加载完成后的回调（主线程执行）
#func _on_video_loaded(page_index:int, video_stream:VideoStream):
#	# 隐藏加载面板
#	loading_panel.hide()
#	#显示视频和文字
#	video_player.show()
#	rich_label.show()
#	#恢复
#	left_btn.disabled=false
#	right_btn.disabled=false
#
#	# 仅处理当前选中的页面（避免线程切换导致的索引错乱）
#	if page_index != current_page:
#		return
#
#	# 设置视频流并播放
#	video_player.stream = video_stream
#	video_player.play()
#
#
#	# 打印播放状态
#	#print("is_video_playing:" + str(video_player.is_playing()))
#
#func _exit_tree():
#	# 程序退出时停止线程，避免内存泄漏
#	if load_thread and load_thread.is_active():
#		load_thread.wait_to_finish()
