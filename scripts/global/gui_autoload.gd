extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var viewport_size=get_viewport().size
#var center_pos:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	print("viewport_size:"+str(viewport_size))
	var index=int(DataMgr.get_setting("display","resolution"))
	print(index)
	if index==0:
		OS.set_window_size(Vector2(1920,1080))
	if index==1:
		OS.set_window_size(Vector2(1280,720))
	var is_full_screen=DataMgr.get_setting("display","is_full_screen")
	if is_full_screen:
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_fullscreen(false)
		var is_boarderless=DataMgr.get_setting("display","is_borderless_window")
		if is_boarderless:
			OS.set_borderless_window(true)
		else:
			OS.set_borderless_window(false)
	# 监听场景树变化信号（窗口就绪后触发）
	get_tree().connect("tree_changed", self, "_on_tree_ready")
	# 或监听屏幕尺寸变化信号（窗口初始化时会触发一次）
	# get_tree().connect("screen_resized", self, "_on_screen_ready")


var is_centered = false  # 避免重复居中



func _on_tree_ready():
	# 确保只执行一次居中（避免信号重复触发）
	if not is_centered and OS.get_window_size().x > 0:  # 窗口尺寸有效
		OS.center_window()
		is_centered = true
		print("自动加载：窗口就绪后居中")

# 备选：监听屏幕就绪信号
func _on_screen_ready():
	if not is_centered:
		OS.center_window()
		is_centered = true
