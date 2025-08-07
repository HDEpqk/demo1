# DataMgr.gd
extends Node

const CONFIG_PATH = "user://game_settings.cfg"
var _config = ConfigFile.new()

#leancloud相关
var rank_limited_dic:Dictionary={}
var rank_endless_dic:Dictionary={}
const LIMITED_BOARDER="LimitedTimeScore"#限时排行榜名称
const ENDLESS_BOARDER="EndlessTimeScore"#无尽排行榜名称
const APP_ID="X-LC-Id: OMCWyoTJdgvCJxObvbCAISTF-gzGzoHsz"
const APP_KEY="X-LC-Key: la1EnPLVmpsW5QcWuONzIwj4"
const MASTER_KEY="X-LC-Key: yWwSlbbhoi4tFSEOYLXnd8lY,master"
const REST_API="https://omcwyotj.lc-cn-n1-shared.com"#临时的REST API 服务器地址

var CACHE_EXPIRE_SECONDS = 30  # 缓存有效期（一天）测试用30s
const LIMITED_BOARDER_MAX_NUM:int=11#限时排行榜最大人数
const ENDLESS_BOARDER_MAX_NUM:int=11#无尽排行榜最大人数
var is_over_LIMITED_BOARDER_MAX_NUM:bool=false#是否超出限时排行榜最大人数
var is_over_ENDLESS_BOARDER_MAX_NUM:bool=false#是否超出限时排行榜最大人数


onready var instance=self

# 默认配置（首次运行时初始化）
var default_settings = {
	"audio": {
		"music_enabled": true,
		"sound_enabled": true,
	},
	"user": {
		"user_id":"",
		"nick_name":"",
		"highest_score": 0
	},
	"leancloud": {
		"cache_limited_obj":{#rank_limited_dic的本地缓存对象
			"rank_limited_dic":{},
			"timestamp": 0
		},
		"cache_endless_obj":{#rank_endless_dic的本地缓存对象
			"rank_endless_dic":{},
			"timestamp": 0
		}
	}
}
func is_limited_cache_valid() -> bool:
	# 获取缓存数据
	var cache_data = get_setting("leancloud", "cache_limited_obj")
	# 验证缓存数据结构是否完整
	if not cache_data.has("timestamp") or not cache_data.has("rank_limited_dic"):
		print("缓存数据结构不完整，视为无效")
		return false
	
	var cache_timestamp = cache_data["timestamp"]
	var rank_limited_dic = cache_data["rank_limited_dic"]
	var current_time = Time.get_unix_time_from_system()
	
	var cache_timestamp_type=typeof(cache_timestamp)
	print("cache_timestamp_type:",cache_timestamp_type)
	# 验证时间戳是否为有效数字（防止字符串或其他类型）
	if cache_timestamp_type != TYPE_INT:
		print("缓存时间戳类型错误，视为无效")
		return false
	
	# 计算时间差（如果缓存时间在未来，强制视为无效）
	var delta_time = current_time - cache_timestamp
	if delta_time < 0:
		print("缓存时间戳在未来（可能系统时间被修改），视为无效")
		return false
	
	# 检查数据有效性和过期时间
	var is_data_valid = !rank_limited_dic.empty()
	var is_not_expired = delta_time < CACHE_EXPIRE_SECONDS
	
	return is_data_valid && is_not_expired

# 检查rank_endless_dic缓存是否有效
func is_endless_cache_valid() -> bool:
	var cache_timestamp=get_setting("leancloud","cache_endless_obj")["timestamp"]
	return rank_endless_dic.size() > 0 && (Time.get_unix_time_from_system()
	- cache_timestamp) < CACHE_EXPIRE_SECONDS
	
func fetch_leaderboarder_player(boarder_name)->bool:
	if boarder_name==LIMITED_BOARDER:
		if is_limited_cache_valid():
			DebugUtils.log("使用本地缓存")
			#如果当天查询过一次就拿取本地缓存的数据赋值给内存中的字典
			rank_limited_dic=get_setting("leancloud","cache_limited_obj")["rank_limited_dic"]
			if check_if_rank_dic_over_max_num(rank_limited_dic,LIMITED_BOARDER_MAX_NUM):
				is_over_LIMITED_BOARDER_MAX_NUM=true
			# 函数执行完毕，发射信号
			EventBus.fire_event("http_fetch_request_completed")
			return true
	elif boarder_name==ENDLESS_BOARDER:
		if is_endless_cache_valid():
			DebugUtils.log("使用本地缓存")
			#如果当天查询过一次就拿取本地缓存的数据赋值给内存中的字典
			rank_endless_dic=get_setting("leancloud","rank_endless_dic")["rank_endless_dic"]
			if check_if_rank_dic_over_max_num(rank_endless_dic,ENDLESS_BOARDER_MAX_NUM):
				is_over_ENDLESS_BOARDER_MAX_NUM=true
			# 函数执行完毕，发射信号
			EventBus.fire_event("http_fetch_request_completed")
			return true
	DebugUtils.log("fetch request")
	var http_request:=HTTPRequest.new()
	add_child(http_request)
	http_request.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request.connect("request_completed", self, "_http_fetch_request_completed")
	var url=REST_API+"/1.1/leaderboard/leaderboards/user/"+boarder_name+"/ranks"
	# 执行 GET 请求。截止到文档编写时，下面的 URL 会返回 JSON。
	var error = http_request.request(
		url,
		[APP_ID,APP_KEY]
		)
	if error != OK:
		push_error("fetch_leaderboarder_player请求发生了错误。")
		return false
	else:
		return true


# 将在 HTTP 请求完成时调用。
func _http_fetch_request_completed(result, response_code, headers, body):
	DebugUtils.log("fetch finished")
	print(body.get_string_from_utf8())
	var data := parse_json(body.get_string_from_utf8()) as Dictionary
	var cache_timestamp:int=Time.get_unix_time_from_system()
#{
#    "results": [
#        {
#            "statisticName": "Score",
#            "statisticValue": 5,
#            "rank": 0,
#            "entity": "user1"
#        }
#    ]
#}
	var results:=data['results'] as Array
	if results.empty():
		push_warning("request请求结果为空")
		return
	if results[0]['statisticName']==LIMITED_BOARDER:
		for r in results:
			rank_limited_dic[r['entity']]=r['statisticValue']
		set_setting("leancloud","cache_limited_obj",
		{"rank_limited_dic":rank_limited_dic,"timestamp":cache_timestamp})
		if check_if_rank_dic_over_max_num(rank_limited_dic,LIMITED_BOARDER_MAX_NUM):
			is_over_LIMITED_BOARDER_MAX_NUM=true
	elif results[0]['statisticName']==ENDLESS_BOARDER:
		for r in results:
			rank_endless_dic[r['entity']]=r['statisticValue']
		set_setting("leancloud","cache_endless_obj",
		{"rank_endless_dic":rank_endless_dic,"timestamp":cache_timestamp})
		if check_if_rank_dic_over_max_num(rank_endless_dic,ENDLESS_BOARDER_MAX_NUM):
			is_over_ENDLESS_BOARDER_MAX_NUM=true
	
	# 函数执行完毕，发射信号
	EventBus.fire_event("http_fetch_request_completed")

func check_if_rank_dic_over_max_num(rank_dic:Dictionary,max_num:int)->bool:
	return rank_dic.size()>max_num
	

func update_leaderboarder_player(boarder_name)->bool:
	DebugUtils.log("update request")
	var http_request:=HTTPRequest.new()
	add_child(http_request)
	http_request.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request.connect("request_completed", self, "_http_update_request_completed")
	#获取uid
	var uid = get_setting("user", "user_id")

	var url=REST_API+"/1.1/leaderboard/users/%s/statistics" % uid
	var error = http_request.request(
		url,
		 [APP_ID,
		MASTER_KEY,
		"Content-Type: application/json"],
		true,
		HTTPClient.METHOD_POST, 
		JSON.print([{"statisticName": boarder_name, "statisticValue": Global.score}]))

	if error != OK:
		push_error("update_leaderboarder_player请求发生了错误。")
		return false
	else:
		return true

func _http_update_request_completed(result, response_code, headers, body):
	DebugUtils.log("update finished")

func delete_leaderboarder_player(boarder_name,uid)->bool:
	DebugUtils.log("delete request")
	var http_request:=HTTPRequest.new()
	add_child(http_request)
	http_request.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request.connect("request_completed", self, "_http_update_request_completed")

	var url=REST_API+"/1.1/leaderboard/users/%s/statistics" % uid+"?statistics="+boarder_name
	var error = http_request.request(
		url,
		 [APP_ID,
		MASTER_KEY,
		"Content-Type: application/json"],
		true,
		HTTPClient.METHOD_DELETE)

	if error != OK:
		push_error("delete_leaderboarder_player请求发生了错误。")
		return false
	else:
		return true
	

#用户管理
func create_user(nickname)->bool:
	DebugUtils.log("create_user")
	var http_request:=HTTPRequest.new()
	add_child(http_request)
	http_request.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request.connect("request_completed", self, "_http_create_user_completed")
	print("nickname:",nickname)
	var url=REST_API+"/1.1/users"
	var error = http_request.request(
		url,
		 [APP_ID,
		MASTER_KEY,
		"Content-Type: application/json"],
		true,
		HTTPClient.METHOD_POST,
		JSON.print({"username":nickname,"password":"123"}))
	print("error:",error)
	if error != OK:
		push_error("create_user请求发生了错误。")
		return false
	else:
		return true
func _http_create_user_completed(result, response_code, headers, body):
	var is_success=true
	#网络层异常
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("请求失败：网络错误或超时")
		is_success=false
	print(body.get_string_from_utf8())
	# 解析响应体
	var response_data = parse_json(body.get_string_from_utf8())
	
	# 业务异常判断（包含特定错误码或非预期状态码）
	if response_data.has("error"):
		is_success=false
	
	# 函数执行完毕，发射信号
	EventBus.fire_event("http_create_user_completed",is_success)

func read_user()->bool:
	DebugUtils.log("read_user")
	var http_request:=HTTPRequest.new()
	add_child(http_request)
	http_request.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request.connect("request_completed", self, "_http_read_user_completed")
	# 1. 获取昵称
	var nickname = get_setting("user", "nick_name")
	var url=REST_API+"/1.1/users"+"?where={\"username\":\"%s\"}" % nickname
	print("read_user_url:",url)
	var error = http_request.request(
		url,
		 [APP_ID,
		MASTER_KEY],
		true,
		HTTPClient.METHOD_GET)

	if error != OK:
		push_error("create_user请求发生了错误。")
		return false
	else:
		return true

func _http_read_user_completed(result, response_code, headers, body):
	print(body.get_string_from_utf8())
	var data := parse_json(body.get_string_from_utf8()) as Dictionary
	var results:=data['results'] as Array
	if results.empty():
		push_warning("request请求结果为空")
		return
#	{
#    "results": [
#        {
#            "updatedAt": "2025-08-06T11:48:13.548Z",
#            "objectId": "689340fd9bf5cd01d7aeb520",
#            "username": "test1",
#            "shortId": "vqfhjc",
#            "createdAt": "2025-08-06T11:48:13.548Z",
#            "emailVerified": false,
#            "mobilePhoneVerified": false
#        }
#    ]
#}
	EventBus.fire_event("http_read_user_completed",results[0])
	pass
	
	

# 单例初始化
func _ready():
	# 从本地加载配置
	load_settings()

	

# 加载配置
func load_settings():
	var err = _config.load(CONFIG_PATH)
	if err == OK:  # 文件存在
		# 遍历所有section和key，用文件值覆盖默认值
		for section in default_settings:
			for key in default_settings[section]:
				var value = _config.get_value(section, key, default_settings[section][key])
				default_settings[section][key] = value
	else:  # 首次运行，创建默认配置
		save_settings()

# 保存配置
func save_settings():
	for section in default_settings:
		for key in default_settings[section]:
			_config.set_value(section, key, default_settings[section][key])
	_config.save(CONFIG_PATH)

# 对外接口：获取设置值
func get_setting(section, key):
	return default_settings.get(section, {}).get(key, null)

# 对外接口：修改设置值（自动保存）
func set_setting(section, key, value):
	if section in default_settings and key in default_settings[section]:
		default_settings[section][key] = value
		save_settings()


