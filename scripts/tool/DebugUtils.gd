# 全局脚本（如 DebugUtils.gd）
class_name DebugUtils

static func log(message):
	if OS.is_debug_build():
		print(message)
