extends Node2D


onready var window_mode:OptionButton = $CanvasLayer/HBoxContainer/window_mode
onready var resolution = $CanvasLayer/HBoxContainer/Resolution


##在window模式下切换到另外两种模式后再返回window模式，此时调整1920以上的分辨率会让摄像机放大


func _ready():
	var platform=OS.get_name()
	if platform == "Android" or platform == "iOS":
		window_mode.disabled=true
		window_mode.visible=false
		resolution.disabled=true
		resolution.visible=false
		return

	window_mode.add_item("全屏",0)
	window_mode.add_item("窗口",1)
	window_mode.add_item("无边框窗口",2)
#	resolution.add_item("3840x2160",0)
#	resolution.add_item("2560x1440",1)
	resolution.add_item("1920x1080",0)
	resolution.add_item("1280x720",1)
	
	var index=int(DataMgr.get_setting("display","resolution"))
	if index==0:
		resolution.select(0)
	if index==1:
		resolution.select(1)
	

	var is_fullscreen=DataMgr.get_setting("display","is_full_screen")
	print("is_window_fullscreen:",is_fullscreen)	
	if is_fullscreen:
		window_mode.select(0)
		resolution.hide()
		resolution.disabled=true
	else:
		var is_boaderless=DataMgr.get_setting("display","is_borderless_window")
		if is_boaderless:
			window_mode.select(2)
			resolution.show()
			resolution.disabled=false
		else:
			window_mode.select(1)
			resolution.show()
			resolution.disabled=false
		OS.center_window()



		
func _on_window_mode_item_selected(index):
	if index==0:
		OS.set_window_fullscreen(true)
		OS.set_borderless_window(false)
		DataMgr.set_setting("display","is_full_screen",true)
		DataMgr.set_setting("display","is_borderless_window",false)
		resolution.hide()
		resolution.disabled=true
	elif index==1:
		OS.set_window_fullscreen(false)
		OS.set_borderless_window(false)
		DataMgr.set_setting("display","is_full_screen",false)
		DataMgr.set_setting("display","is_borderless_window",false)
		resolution.show()
		resolution.disabled=false
	elif index==2:
		OS.set_window_fullscreen(false)
		OS.set_borderless_window(true)
		DataMgr.set_setting("display","is_full_screen",false)		
		DataMgr.set_setting("display","is_borderless_window",true)
		resolution.show()
		resolution.disabled=false
	OS.center_window()


func _on_Resolution_item_selected(index):
	if index==0:
		OS.set_window_size(Vector2(1920,1080))
		DataMgr.set_setting("display","resolution",0)
		print("设置1080p")
	if index==1:
		OS.set_window_size(Vector2(1280,720))
		DataMgr.set_setting("display","resolution",1)
		print("设置720p")
		
	OS.center_window()




