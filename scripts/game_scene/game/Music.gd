extends Node2D


onready var music_list = []
var current_index = 0       # 当前播放索引
var drawer
onready var music_player =$AudioStreamPlayer
onready var sfx_player=$AudioStreamPlayerSFX
var is_bgm_on
var scene_info

func _ready():
	#获取音乐完整路径
	music_list= get_files_by_extension("res://audio/music/three-red-hearts-prepare-to-dev-download/","oggstr")
	drawer = RandomDrawer.new(music_list)
		#从配置文件读取音乐是否被禁用
	is_bgm_on=DataMgr.get_setting("audio","music_enabled")
	play_next_song()
	#绑定游戏结束事件
	EventBus.connect_event("game_over",self,"_on_game_over")
	

func _on_game_over(info):
	scene_info=info
	if music_player.is_playing():
		music_player.stop()
	sfx_player.stream=load("res://audio/sfx/GameOverSFX_1.wav")
	if sfx_player.stream!=null:
		sfx_player.play()
	
	

func play_next_song():
	if !is_bgm_on:return
	if music_list==null:return
	
	# 抽取所有元素（不重复）
	var item = drawer.next()
	if item == null:
		#所有音乐播放完后重置drawer
		drawer.reset()
		#播放第一首
		item=drawer.next()
	DebugUtils.log("当前播放的bgm为："+item)
	var music=load(item)
	music_player.stream = music
	music_player.play()



func _on_AudioStreamPlayer_finished():
	play_next_song()

# 获取文件夹中所有文件名（不含路径）
func get_file_names_in_directory(path: String) -> Array:
	var file_names = []
	var dir = Directory.new()
	
	# 检查目录是否存在
	if not dir.dir_exists(path):
		push_error("目录不存在: " + path)
		return file_names
	
	# 打开目录
	if dir.open(path) != OK:
		push_error("无法打开目录: " + path)
		return file_names
	
	# 开始读取目录内容
	dir.list_dir_begin(true)  # true 表示跳过导航目录（. 和 ..）
	
	# 遍历所有文件
	var file_name = dir.get_next()
	while file_name != "":
		# 跳过目录，只保留文件
		if not dir.current_is_dir():
			file_names.append(file_name)
		file_name = dir.get_next()
	
	# 结束读取
	dir.list_dir_end()
	
	return file_names

# 获取文件夹中所有文件的完整路径
func get_file_paths_in_directory(path: String) -> Array:
	var file_paths = []
	var file_names = get_file_names_in_directory(path)
	
	for file_name in file_names:
		file_paths.append(path.plus_file(file_name))
	
	return file_paths

#过滤特定类型文件
func get_files_by_extension(path: String, extension: String) -> Array:
	var all_files = get_file_paths_in_directory(path)
	var filtered = []
	
	for file in all_files:
		if file.get_extension().to_lower() == extension.to_lower():
			filtered.append(file)
	
	return filtered

# 创建随机抽取器类
class RandomDrawer:
	var _items: Array
	var _index: int = 0
	
	func _init(items: Array):
		_items = items.duplicate()
		_items=shuffle_array(_items)  # 初始化时洗牌
		#print("_items:after shuffle_array"+str(_items))
		

	# 使用 Fisher-Yates 算法随机打乱数组
	func shuffle_array(arr: Array) -> Array:
		var n = arr.size()
		for i in range(n - 1, 0, -1):
			# 生成 0 到 i 之间的随机索引
			var j = randi() % (i + 1)
			# 交换元素
			var temp = arr[i]
			arr[i] = arr[j]
			arr[j] = temp
		return arr
	# 获取下一个随机元素
	func next():
		if _index >= _items.size():
			return null
		var item = _items[_index]
		_index += 1
		return item
	
	# 重置抽取器（可选）
	func reset():
		_index = 0
		_items=shuffle_array(_items)


func _on_AudioStreamPlayerSFX_finished():
	#跳转到结束界面
	SceneMgr.change_scene_with_info("res://scene/game_scene/end/GameOverScene.tscn",scene_info)
