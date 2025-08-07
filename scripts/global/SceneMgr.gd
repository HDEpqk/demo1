# SceneManager.gd - 作为自动加载的单例
extends Node

var scene_history = []  # 存储场景路径的历史记录
var scene_info
var game_scene_name


# 切换到新场景并记录当前场景
func change_scene(scene_path: String) -> void:
	# 记录当前场景路径
	if get_tree().current_scene:
		scene_history.append(get_tree().current_scene.filename)
	
	# 加载并切换到新场景
	var scene = load(scene_path)
	get_tree().change_scene_to(scene)
# 切换到新场景并记录当前场景,可传递信息
func change_scene_with_info(scene_path: String,info:String) -> void:
	scene_info=info
	# 记录当前场景路径
	if get_tree().current_scene:
		scene_history.append(get_tree().current_scene.filename)
	
	# 加载并切换到新场景
	var scene = load(scene_path)
	get_tree().change_scene_to(scene)

# 返回上一个场景
func return_to_previous() -> void:
	if scene_history.size() > 0:
		var previous_scene = scene_history.pop_back()
		change_scene(previous_scene)
	else:
		print("没有上一个场景可返回")
