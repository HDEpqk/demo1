extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var viewport_size =GuiAutoload.viewport_size

# Called when the node enters the scene tree for the first time.
func _ready():
	# 方法1：使用字符串分割（推荐，简单直接）
	var parts = name.split("_")  # 按"_"分割成数组 ["level", "1"]
	if parts.size() == 2:
		var level_number = int(parts[1])  # 转换为整数 1
		if $PassedLevel !=null:
			$PassedLevel.init_passed_level(level_number)
	#取消暂停
	get_tree().paused=false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
