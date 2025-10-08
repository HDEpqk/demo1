# DataMgr.gd
extends Node



#leancloud相关
var rank_limited_dic:Dictionary={}
var rank_endless_dic:Dictionary={}
const LIMITED_BOARDER="LimitedTimeScore"#限时排行榜名称
const ENDLESS_BOARDER="EndlessTimeScore"#无尽排行榜名称
# 加密后的敏感信息（从临时脚本的输出复制）
const ENCRYPTED_APP_ID:=PoolByteArray([106,30,127,34,78,126,7,10,127,40,44,46,50,38,10,101,43,0,86,71,
38,46,26,119,84,18,90,115,119,44,101,50,112,72,81,67,113,73,93,123,64,27])
const ENCRYPTED_APP_KEY:=PoolByteArray([106,30,127,34,78,124,6,73,101,71,
13,12,84,26,11,97,45,50,92,65,22,51,87,105,85,51,77,127,120,31,127,17,92,81])
const ENCRYPTED_MASTER_KEY:=PoolByteArray([106,30,127,34,78,124,6,73,101,71,24,58,18,
12,9,83,3,12,94,88,81,16,36,107,115,43,97,124,110,11,82,94,90,60,26,84,87,64,70,86,65])
const ENCRYPTED_REST_API:=PoolByteArray([90,71,71,17,16,13,76,31,48,10,2,26,28,48,17,91,
79,8,82,28,6,10,79,86,7,73,75,88,87,23,83,2,24,6,89,84])
const ENCRYPTED_KEY:=PoolByteArray([70,86,94,17,60,92,6,73,43,2,12,29,58,52,0,72,21,
1,92,65,58,15,7,65,66,1,85,64,105,14,83,31,66,0,91,73,105,88])



var app_id
var key="my_key"
var dabgjl="ey"
var app_key
var adaigkey
var master_key
var rest_api#临时的REST API 服务器地址
var agakmka="te"
var gjaiofnak="mp_k"

const BOARDER_CACHE_EXPIRE_SECONDS:= 86400  # 排行榜缓存有效期（实际一天或者5min，测试用0s）
const LIMITED_BOARDER_MAX_NUM:=11#限时排行榜最大人数
const ENDLESS_BOARDER_MAX_NUM:=11#无尽排行榜最大人数
#var is_over_LIMITED_BOARDER_MAX_NUM:bool=false#是否超出限时排行榜最大人数
#var is_over_ENDLESS_BOARDER_MAX_NUM:bool=false#是否超出限时排行榜最大人数

#上传分数相关
const LIMITED_UPLOAD_TATOL_COUNT:=3#限时上传总次数
const ENDLESS_UPLOAD_TATOL_COUNT:=3#无尽上传总次数
const UPLOAD_COUNT_RESET_SECONDS:= 86400  #上传次数重置时间（实际一天，测试用30s）

onready var instance=self


	



#func first_set_upload_timestamp():
#	#游戏每天第一次启动就记录一下时间戳
#	var is_set_upload_timestamp=get_setting("user","is_set_upload_timestamp")
#	if is_set_upload_timestamp:return
#	else:
#		var current_time = Time.get_unix_time_from_system()
#		DataMgr.set_setting("user","upload_timestamp",current_time)
#		DataMgr.set_setting("user","is_set_upload_timestamp",true)

func check_is_reset_upload_count():
	#检查是否需要重置upload次数
	# 获取缓存数据
	var upload_timestamp = int(get_setting("user","upload_timestamp"))
	var current_time = Time.get_unix_time_from_system()
		
	var cache_timestamp_type=typeof(upload_timestamp)
	# 验证时间戳是否为有效数字（防止字符串或其他类型）
	if cache_timestamp_type != TYPE_INT:
		print("缓存时间戳类型错误，视为无效")
		return false
	# 计算时间差（如果缓存时间在未来，强制视为无效）
	var delta_time = current_time - upload_timestamp
	if delta_time < 0:
		print("缓存时间戳在未来（可能系统时间被修改），视为无效")
		return false
	if delta_time > UPLOAD_COUNT_RESET_SECONDS:
		DebugUtils.log("delta_time > UPLOAD_COUNT_RESET_SECONDS")
		DataMgr.set_setting("user","limited_upload_current_count",LIMITED_UPLOAD_TATOL_COUNT)
		DataMgr.set_setting("user","endless_upload_current_count",ENDLESS_UPLOAD_TATOL_COUNT)
		#过了规定时间重新记录当前时间为时间戳
		DataMgr.set_setting("user","upload_timestamp",current_time)
		#DataMgr.set_setting("user","is_set_upload_timestamp",false)
	else:
		DebugUtils.log("delta_time < UPLOAD_COUNT_RESET_SECONDS")
		
		
	


func is_limited_upload_valid() -> bool:
	#检查限时排行榜是否能上传分数
	if DataMgr.get_setting("user","limited_upload_current_count")<=0:return false
	else:return true
	
func is_endless_upload_valid() -> bool:
	#检查无尽排行榜是否能上传分数
	if DataMgr.get_setting("user","endless_upload_current_count")<=0:return false
	else:return true


func is_limited_cache_valid() -> bool:
	# 获取缓存数据
	var cache_data = get_setting("leancloud", "cache_limited_obj")
	# 验证缓存数据结构是否完整
	if not cache_data.has("timestamp") or not cache_data.has("rank_limited_dic"):
		print("缓存数据结构不完整，视为无效")
		return false
	
	var cache_timestamp = int(cache_data["timestamp"])
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
	var is_not_expired = delta_time < BOARDER_CACHE_EXPIRE_SECONDS
	
	return is_data_valid && is_not_expired

# 检查rank_endless_dic缓存是否有效
func is_endless_cache_valid() -> bool:
	# 获取缓存数据
	var cache_data = get_setting("leancloud", "cache_endless_obj")
	# 验证缓存数据结构是否完整
	if not cache_data.has("timestamp") or not cache_data.has("rank_endless_dic"):
		print("缓存数据结构不完整，视为无效")
		return false
	
	var cache_timestamp = int(cache_data["timestamp"])
	var rank_endless_dic = cache_data["rank_endless_dic"]
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
	var is_data_valid = !rank_endless_dic.empty()
	var is_not_expired = delta_time < BOARDER_CACHE_EXPIRE_SECONDS
	
	return is_data_valid && is_not_expired
	
func fetch_leaderboarder_player(boarder_name)->bool:
	# 定义当前排行榜对应的最大人数限制
	var max_num = 0
	if boarder_name == LIMITED_BOARDER:
		max_num = LIMITED_BOARDER_MAX_NUM
	elif boarder_name == ENDLESS_BOARDER:
		max_num = ENDLESS_BOARDER_MAX_NUM
	else:
		push_error("未知的排行榜名称")
		return false

	# 本地缓存逻辑（保持不变，但需确保缓存也受限于最大人数）
	if boarder_name == LIMITED_BOARDER and is_limited_cache_valid():
		DebugUtils.log("使用本地缓存")
		rank_limited_dic = get_setting("leancloud", "cache_limited_obj")["rank_limited_dic"]
		# 截取缓存中前 max_num 条数据（确保缓存不超过限制）
		rank_limited_dic = cut_dic_to_max_num(rank_limited_dic, max_num)
		#is_over_LIMITED_BOARDER_MAX_NUM = check_if_rank_dic_over_max_num(rank_limited_dic, max_num)
		EventBus.fire_event("http_fetch_request_completed")
		return true
	elif boarder_name == ENDLESS_BOARDER and is_endless_cache_valid():
		DebugUtils.log("使用本地缓存")
		rank_endless_dic = get_setting("leancloud", "cache_endless_obj")["rank_endless_dic"]
		# 截取缓存中前 max_num 条数据
		rank_endless_dic = cut_dic_to_max_num(rank_endless_dic, max_num)
		#is_over_ENDLESS_BOARDER_MAX_NUM = check_if_rank_dic_over_max_num(rank_endless_dic, max_num)
		EventBus.fire_event("http_fetch_request_completed")
		return true

	# 网络请求：URL 中添加 limit 参数限制返回数量
	DebugUtils.log("fetch request (限制最多 %d 条)" % max_num)
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request.connect("request_completed", self, "_http_fetch_request_completed",[http_request])
	# 构造 URL 时添加 ?limit=xxx 参数（注意：如果 URL 已有其他参数，用 & 连接）
	var url = "%s/1.1/leaderboard/leaderboards/user/%s/ranks?limit=%d" % [rest_api, boarder_name, max_num]
	
	var error = http_request.request(
		url,
		[app_id, app_key]
	)
	if error != OK:
		push_error("fetch_leaderboarder_player请求发生了错误。")
		return false
	else:
		return true

# 辅助函数：截取字典中前 N 条数据（按排名/插入顺序）
func cut_dic_to_max_num(src_dic: Dictionary, max_num: int) -> Dictionary:
	var new_dic = {}
	var count = 0
	for key in src_dic:
		if count >= max_num:
			break
		new_dic[key] = src_dic[key]
		count += 1
	return new_dic


# 将在 HTTP 请求完成时调用。
func _http_fetch_request_completed(result, response_code, headers, body,http_request):
	# 先检查是否为网络错误
	if is_network_error(result):
		#清理节点
		http_request.queue_free()
		return  # 网络错误已处理，终止后续逻辑
	
	# 非网络错误：检查请求是否成功
	if result != HTTPRequest.RESULT_SUCCESS:
		push_warning("请求失败（非网络问题），错误码："+str(result))
		#清理节点
		http_request.queue_free()
		return
	DebugUtils.log("fetch finished")
	var json_str=body.get_string_from_utf8() as String
	var data :Dictionary={}
	data = parse_json(json_str) as Dictionary

	# 检查解析结果是否为Dictionary
	if data is Dictionary:
		# 解析成功且是字典类型，进行后续处理
		var cache_timestamp:int=Time.get_unix_time_from_system()
		var results: Array = []  # 默认为空数组，避免后续使用时报错
		# 判断data包含 'results' 键，且对应的值是数组
		if data.has("results"):
			results = data["results"] as Array
		else:
			# 可选：处理键不存在或类型错误的情况（如打印日志）
			push_error("数据中没有有效的 'results' 数组")
		if results.empty():
			push_error("request请求结果为空")
			#清理节点
			http_request.queue_free()
			return
		if results[0]['statisticName']==LIMITED_BOARDER:
			for r in results:
				rank_limited_dic[r['entity']]={"score":r['statisticValue'],"rank":r['rank']}
			set_setting("leancloud","cache_limited_obj",
			{"rank_limited_dic":rank_limited_dic,"timestamp":cache_timestamp})
	#		if check_if_rank_dic_over_max_num(rank_limited_dic,LIMITED_BOARDER_MAX_NUM):
	#			is_over_LIMITED_BOARDER_MAX_NUM=true
			# 函数执行完毕，发射信号
			EventBus.fire_event("http_fetch_request_completed")
		elif results[0]['statisticName']==ENDLESS_BOARDER:
			for r in results:
				rank_endless_dic[r['entity']]={"score":r['statisticValue'],"rank":r['rank']}
			set_setting("leancloud","cache_endless_obj",
			{"rank_endless_dic":rank_endless_dic,"timestamp":cache_timestamp})
	#		if check_if_rank_dic_over_max_num(rank_endless_dic,ENDLESS_BOARDER_MAX_NUM):
	#			is_over_ENDLESS_BOARDER_MAX_NUM=true
			# 函数执行完毕，发射信号
			EventBus.fire_event("http_fetch_request_completed")
	else:
		# 处理错误情况
		push_error("JSON解析错误或类型不是Dictionary")
		push_error("原始JSON字符串: "+json_str)
		push_error("解析结果类型: "+str(typeof(data)))

	#清理节点
	http_request.queue_free()


#func check_if_rank_dic_over_max_num(rank_dic:Dictionary,max_num:int)->bool:
#	return rank_dic.size()>max_num
	

func update_leaderboarder_player(boarder_name)->bool:
	DebugUtils.log("update request")
	var http_request:=HTTPRequest.new()
	add_child(http_request)
	http_request.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request.connect("request_completed", self, "_http_update_request_completed",[http_request,boarder_name])
	#获取uid
	var uid = get_setting("user", "user_id")

	var url="%s/1.1/leaderboard/users/%s/statistics" % [rest_api,uid]
	var error = http_request.request(
		url,
		 [app_id,
		master_key,
		"Content-Type: application/json"],
		true,
		HTTPClient.METHOD_POST, 
		JSON.print([{"statisticName": boarder_name, "statisticValue": Global.score}]))

	if error != OK:
		push_error("update_leaderboarder_player请求发生了错误。")
		return false
	else:
		return true

func _http_update_request_completed(result, response_code, headers, body,http_request,boarder_name):
	# 先检查是否为网络错误
	if is_network_error(result):
		#清理节点
		http_request.queue_free()
		return  # 网络错误已处理，终止后续逻辑
	
	# 非网络错误：检查请求是否成功
	if result != HTTPRequest.RESULT_SUCCESS:
		push_warning("请求失败（非网络问题），错误码："+str(result))
		#清理节点
		http_request.queue_free()
		return
	DebugUtils.log("update success")
	EventBus.fire_event("http_update_request_completed",Global.score)
	
	#更新排行榜后刷新排行榜信息
	var max_num = 0
	if boarder_name == LIMITED_BOARDER:
		max_num = LIMITED_BOARDER_MAX_NUM
	elif boarder_name == ENDLESS_BOARDER:
		max_num = ENDLESS_BOARDER_MAX_NUM
	else:
		push_error("未知的排行榜名称")
		return false
	#清理节点
	http_request.queue_free()
	DebugUtils.log("更新排行榜后刷新排行榜信息")
	var http_request2 := HTTPRequest.new()
	add_child(http_request2)
	http_request2.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request2.connect("request_completed", self, "_http_fetch_request_completed",[http_request2])
	# 构造 URL 时添加 ?limit=xxx 参数（注意：如果 URL 已有其他参数，用 & 连接）
	var url = "%s/1.1/leaderboard/leaderboards/user/%s/ranks?limit=%d" % [rest_api, boarder_name, max_num]
	
	var error = http_request2.request(
		url,
		[app_id, app_key]
	)
	if error != OK:
		push_error("fetch_leaderboarder_player请求发生了错误。")
		return false
	else:
		return true

func delete_leaderboarder_player(boarder_name,uid)->bool:
	DebugUtils.log("delete request")
	var http_request:=HTTPRequest.new()
	add_child(http_request)
	http_request.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request.connect("request_completed", self, "_http_update_request_completed",[http_request])

	var url="%s/1.1/leaderboard/users/%s/statistics?statistics=%s" % [rest_api,uid,boarder_name]
	var error = http_request.request(
		url,
		 [app_id,
		master_key,
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
	var http_request:=HTTPRequest.new()
	add_child(http_request)
	http_request.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request.connect("request_completed", self, "_http_create_user_completed",[http_request])
	var url="%s/1.1/users" % [rest_api]
	var error = http_request.request(
		url,
		 [app_id,
		master_key,
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
func _http_create_user_completed(result, response_code, headers, body,http_request):
	var is_success = true
	
	# 先检查是否为网络错误
	if is_network_error(result):
		#清理节点
		http_request.queue_free()
		return  # 网络错误已处理，终止后续逻辑
	
	# 非网络错误：检查请求是否成功
	if result != HTTPRequest.RESULT_SUCCESS:
		push_warning("请求失败（非网络问题），错误码："+str(result))
		#清理节点
		http_request.queue_free()
		return
	
	# 业务逻辑处理（原有代码）
	var response_data = parse_json(body.get_string_from_utf8())
	if response_data.has("error"):
		is_success = false
	
	EventBus.fire_event("http_create_user_completed", is_success)
	http_request.queue_free()

func read_user_id_by_name(name:String)->bool:
	#DebugUtils.log("read_user")
	var http_request:=HTTPRequest.new()
	add_child(http_request)
	http_request.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request.connect("request_completed", self, "_http_read_user_id_by_name_completed",[http_request])

	var encoded_name =UrlUtils.url_encode(name)
	var url="%s/1.1/users?where={\"username\":\"%s\"}" % [rest_api,encoded_name]
	#print("read_user_url:",url)
	var error = http_request.request(
		url,
		 [app_id,
		master_key],
		true,
		HTTPClient.METHOD_GET)

	if error != OK:
		push_error("create_user请求发生了错误。")
		return false
	else:
		return true

func _http_read_user_id_by_name_completed(result, response_code, headers, body,http_request):
	# 先检查是否为网络错误
	if is_network_error(result):
		#清理节点
		http_request.queue_free()
		return  # 网络错误已处理，终止后续逻辑
	
	# 非网络错误：检查请求是否成功
	if result != HTTPRequest.RESULT_SUCCESS:
		push_warning("请求失败（非网络问题），错误码："+str(result))
		#清理节点
		http_request.queue_free()
		return
	var json_str=body.get_string_from_utf8() as String
	var data :Dictionary={}
	data = parse_json(json_str) as Dictionary
	var results: Array = []  # 默认为空数组，避免后续使用时报错
	# 先判断 data 是有效的字典，且包含 'results' 键，且对应的值是数组
	if data is Dictionary and data.has("results"):
		results = data["results"] as Array
	else:
		# 可选：处理键不存在或类型错误的情况（如打印日志）
		push_error("数据中没有有效的 'results' 数组")
	if results.empty():
		push_error("request请求结果为空")
		http_request.queue_free()
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
	EventBus.fire_event("http_read_user_id_by_name_completed",results[0]["objectId"])
	http_request.queue_free()
	
func read_user_name_by_id(uid:String)->bool:
	#DebugUtils.log("read_user")
	var http_request:=HTTPRequest.new()
	add_child(http_request)
	http_request.set_pause_mode(PAUSE_MODE_PROCESS)
	http_request.connect("request_completed", self, "_http_read_user_name_by_id_completed",[http_request])

	var url="%s/1.1/users?where={\"objectId\":\"%s\"}" % [rest_api,uid]
	#print("read_user_url:",url)
	var error = http_request.request(
		url,
		 [app_id,
		master_key],
		true,
		HTTPClient.METHOD_GET)

	if error != OK:
		push_error("create_user请求发生了错误。")
		return false
	else:
		return true

func _http_read_user_name_by_id_completed(result, response_code, headers, body,http_request):
	# 先检查是否为网络错误
	if is_network_error(result):
		#清理节点
		http_request.queue_free()
		return  # 网络错误已处理，终止后续逻辑
	
	# 非网络错误：检查请求是否成功
	if result != HTTPRequest.RESULT_SUCCESS:
		push_warning("请求失败（非网络问题），错误码："+str(result))
		#清理节点
		http_request.queue_free()
		return
	var json_str=body.get_string_from_utf8() as String
	#print(json_str)
	var data :Dictionary={}
	data = parse_json(json_str) as Dictionary
	var results: Array = []  # 默认为空数组，避免后续使用时报错
	# 先判断 data 是有效的字典，且包含 'results' 键，且对应的值是数组
	if data is Dictionary and data.has("results"):
		results = data["results"] as Array
	else:
		# 可选：处理键不存在或类型错误的情况（如打印日志）
		push_error("数据中没有有效的 'results' 数组")
	if results.empty():
		push_error("request请求结果为空")
		http_request.queue_free()
		return
	EventBus.fire_event_2param("http_read_user_name_by_id_completed",
	results[0]["objectId"],results[0]["username"])
	http_request.queue_free()

func read_user_rank_by_id(uid: String) -> bool:
	# 1. 检查本地是否已有排行榜数据
	if rank_limited_dic.empty() and rank_endless_dic.empty():
		push_warning("排行榜数据为空，请先调用fetch_leaderboarder_player获取数据")
		return false

	# 2. 存储双榜排名结果（键为排行榜类型，值为排名）
	var rank_results = {
		LIMITED_BOARDER: -1,  # 限时榜排名（-1表示未上榜）
		ENDLESS_BOARDER: -1   # 无尽榜排名
	}

	# 3. 查询限时榜
	if rank_limited_dic.has(uid):
		rank_results[LIMITED_BOARDER] = rank_limited_dic[uid]["rank"] + 1  # 转为1-based

	# 4. 查询无尽榜
	if rank_endless_dic.has(uid):
		rank_results[ENDLESS_BOARDER] = rank_endless_dic[uid]["rank"] + 1  # 转为1-based

	# 5. 发射信号：无论是否上榜，都返回完整结果
	EventBus.fire_event("user_rank_readed",rank_results)
	return true


# 新增：网络错误判断通用方法
# 返回值：true=是网络错误（已处理），false=非网络错误（需后续处理）
func is_network_error(result: int) -> bool:
	# 判断是否为网络相关错误
	var network_errors = [
		HTTPRequest.RESULT_CANT_CONNECT,    # 无法连接服务器
		HTTPRequest.RESULT_CANT_RESOLVE,    # 无法解析域名
		HTTPRequest.RESULT_CONNECTION_ERROR, # 连接过程中出错
		HTTPRequest.RESULT_TIMEOUT           # 请求超时
	]
	
	if result in network_errors:
		var error_msg
		# 根据错误类型生成具体提示信息
		match result:
			HTTPRequest.RESULT_CANT_CONNECT:
				error_msg="无法连接服务器，请检查网络是否通畅"
			HTTPRequest.RESULT_CANT_RESOLVE:
				error_msg="网络异常，无法解析服务器地址"
			HTTPRequest.RESULT_CONNECTION_ERROR:
				error_msg="网络连接中断，请稍后重试"
			HTTPRequest.RESULT_TIMEOUT:
				error_msg="请求超时，服务器未响应"
			_:error_msg="未知网络错误"
		
		# 发射网络错误信号
		EventBus.fire_event("network_error", error_msg)
		return true  # 已处理网络错误
	else:return false

#主动向服务端发送信息来检查网络情况
func is_network_available() -> bool:
	var http_request := HTTPRequest.new()
	var state = {
		is_available = false,
		has_response = false
	}
	add_child(http_request)
	
	# 连接信号（传递 state 字典）
	http_request.connect("request_completed", self, "_on_is_network_available_request_completed", [http_request,state])
	
	var error = http_request.request(rest_api, [], false, HTTPClient.METHOD_HEAD)
	if error != OK:
		return false
	
	return state.is_available and state.has_response

func _on_is_network_available_request_completed(result, response_code, headers, body, http_request,state):

	# 先检查是否为网络错误
	if is_network_error(result):
		#清理节点
		http_request.queue_free()
		return  # 网络错误已处理，终止后续逻辑
	
	# 非网络错误：检查请求是否成功
	if result != HTTPRequest.RESULT_SUCCESS:
		push_warning("请求失败（非网络问题），错误码："+str(result))
		#清理节点
		http_request.queue_free()
		return

	state.has_response = true
	if result == HTTPRequest.RESULT_SUCCESS:
		state.is_available = response_code >= 200 and response_code < 400
		EventBus.fire_event("network_available")
	else:
		state.is_available = false
	#清理节点
	http_request.queue_free()


# 辅助函数：将PoolByteArray转为逗号分隔的字符串
func array_to_string(arr: PoolByteArray) -> String:
	var parts = []
	for byte in arr:
		parts.append(str(byte))
	return ",".join(parts)

func generate_key():
	var device_id = OS.get_unique_id()

	# 1. 移除特殊字符（避免干扰）
	var clean_id = device_id.replace("{", "").replace("}", "").replace("-", "")

	
	# 2. 确保长度至少8位（不足补0，超长截断）
	var safe_device_id = clean_id.pad_zeros(8)  # 补全
	if safe_device_id.length() > 8:
		safe_device_id = safe_device_id.substr(0, 8)  # 超长则截断前8位
	
	# 3. 截取前8位和后8位（此时长度已固定为8位）
	var part1 = safe_device_id.substr(0, 8)
	var part2 = clean_id.right(8)  # 因长度固定，实际与part1相同，可换其他逻辑
	
	# 4. 拼接密钥（增加固定字符串增强复杂度）
	var raw_key = part1 + "_game_" + part2 + "_" + str(randi() % 11)
	return raw_key

# 开发阶段：加密密钥并保存为二进制资源
func save_encrypted_key():
	var raw_key = generate_key()
	var encrypted_key = CryptoUtil.xor_encrypt(raw_key,agakmka+gjaiofnak+dabgjl)
	var resource = Resource.new()
	resource.set_meta("encrypted_key", encrypted_key)
	ResourceSaver.save("res://scripts/tool/encrypted_key.tres", resource)

# 运行阶段：加载并解密密钥
func load_encrypted_key() -> String:
	var resource = load("res://scripts/tool/encrypted_key.tres")
	var encrypted_key = resource.get_meta("encrypted_key") as PoolByteArray
	var decrypted_key=CryptoUtil.xor_decrypt(encrypted_key,agakmka+gjaiofnak+dabgjl)
	return decrypted_key



# 配置文件路径
const CONFIG_PATH = "user://game_settings.cfg"
#const BACKUP_PATH = "user://game_settings.cfg.bak"

# 配置对象和默认设置（全局变量）
#var _config = ConfigFile.new()
# 默认配置（首次运行时初始化）
var default_settings = {
	"audio": {
		"music_enabled": true,
		"sound_enabled": true
	},
	"user": {
		"user_id":"",
		"nick_name":"",
		"upload_limited_score": 0,#上传的限时得分
		"upload_endless_score": 0,#上传的无尽得分
		"highest_limited_score": 0,#最高限时得分
		"highest_endless_score": 0,#最高无尽得分
		"rank_limited":-1,#限时排名
		"rank_endless":-1,#无尽排名
		"limited_upload_current_count":3,#限时上传当前次数，一定时间恢复
		"endless_upload_current_count":3,#无尽上传当前次数，一定时间恢复
		"upload_timestamp": 0,#时间戳,用于记录历史某个时间点#"is_set_upload_timestamp": false #记录游戏第一次启动是否记录了upload_timestamp
		"wuxing_calibration_rect_scale":1
	},
	"leancloud": {
		"cache_limited_obj":{#rank_limited_dic的本地缓存对象
			"rank_limited_dic":{},
			"timestamp": 0#时间戳
		},
		"cache_endless_obj":{#rank_endless_dic的本地缓存对象
			"rank_endless_dic":{},
			"timestamp": 0#时间戳
		}
	},
	"tutorial": {
		"is_first_tutorial":true,#是否进行第一次新手教程
		"is_passed_level_1":true,#是否通过了第一关
		"is_passed_level_2":false,
		"is_passed_level_3":false,
		"is_passed_level_4":false,
		"is_passed_level_5":false,
		"is_passed_level_6":false,
		"is_passed_level_7":false
	}
}


var config_key

# 单例初始化
func _ready():
	#save_encrypted_key()
#	if 3208>8023:
#		DebugUtils.log("3208<8023")
#	elif 3208>3209:
#		DebugUtils.log("wsks")
#	while(false):
#		DebugUtils.log("5201314")
	#adaigkey=load_encrypted_key()
	
	adaigkey=CryptoUtil.xor_decrypt(ENCRYPTED_KEY,agakmka+gjaiofnak+dabgjl)
	app_id=CryptoUtil.xor_decrypt(ENCRYPTED_APP_ID,adaigkey)
	app_key=CryptoUtil.xor_decrypt(ENCRYPTED_APP_KEY,adaigkey)
	master_key=CryptoUtil.xor_decrypt(ENCRYPTED_MASTER_KEY,adaigkey)
	rest_api=CryptoUtil.xor_decrypt(ENCRYPTED_REST_API,adaigkey)
	
	config_key=OS.get_unique_id().sha256_text().substr(0, 32) + "S@l7V@lu3"
	#print("config_key:"+config_key)
	#print("=== 配置系统初始化 ===")
	load_settings()



# 配置对象和默认设置
var _config_data = {}  # 不再使用 ConfigFile
# ... default_settings 保持不变 ...

# 加载配置
func load_settings():
	var file = File.new()
	
	# 尝试读取加密文件
	if file.file_exists(CONFIG_PATH):
		file.open(CONFIG_PATH, File.READ)
		var encrypted = file.get_buffer(file.get_len())
		file.close()
		
		# 解密数据
		var json_str = CryptoUtil.xor_decrypt(encrypted,config_key)
		if json_str:
			var parse_result = JSON.parse(json_str)
			if parse_result.error == OK:
				_config_data = parse_result.result
				
				# 合并数据到默认设置
				merge_settings(default_settings, _config_data)
				return
			else:
				push_error("JSON 解析错误: " + parse_result.error_string)
	
	# 文件不存在或解密失败时使用默认设置
	_config_data = default_settings.duplicate(true)  # 深拷贝
	save_settings()

# 递归合并设置数据
func merge_settings(target, source):
	for key in source:
		if target.has(key):
			if typeof(target[key]) == TYPE_DICTIONARY and typeof(source[key]) == TYPE_DICTIONARY:
				merge_settings(target[key], source[key])
			else:
				target[key] = source[key]
		else:
			target[key] = source[key]

# 保存配置
func save_settings():
	# 转换为 JSON 并加密
	var json_str = JSON.print(_config_data)
	var encrypted = CryptoUtil.xor_encrypt(json_str,config_key)
	
	# 写入加密文件
	var file = File.new()
	if file.open(CONFIG_PATH, File.WRITE) == OK:
		file.store_buffer(encrypted)
		file.close()
	else:
		push_error("无法写入配置文件: " + CONFIG_PATH)

# 获取设置值
func get_setting(section, key):
	if _config_data.has(section) and _config_data[section].has(key):
		return _config_data[section][key]
	return null

# 修改设置值（自动保存）
func set_setting(section, key, value):
	if not _config_data.has(section):
		_config_data[section] = {}
	
	_config_data[section][key] = value
	save_settings()








	



	
