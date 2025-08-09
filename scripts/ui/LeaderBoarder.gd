extends CanvasLayer

onready var lianpu_return = $LianpuReturn
onready var center = $Center
onready var viewport_size = get_viewport().size

onready var tab_container = $"TabContainer"
# 限时相关
onready var rank_limited_dic: Dictionary = {}  # 存储 {用户ID: {分数,排名}}
onready var limited_rank_label = $"TabContainer/限时/Rank"
onready var limited_name_label = $"TabContainer/限时/Name"
onready var limited_score_label = $"TabContainer/限时/Score"

#无尽相关
onready var rank_endless_dic: Dictionary = {}  # 存储 {用户ID: {分数,排名}}
onready var endless_rank_label=$"TabContainer/无尽/Rank"
onready var endless_name_label=$"TabContainer/无尽/Name"
onready var endless_score_label=$"TabContainer/无尽/Score"

#本地玩家信息
onready var local_player_rank=$LocalPlayerInfo/rank
onready var local_player_name=$LocalPlayerInfo/name
onready var local_player_score=$LocalPlayerInfo/score


#用于处理异步查询
var limited_player_ids: Array = []  # 限时排行榜排序后的用户ID列表
var limited_id_to_name: Dictionary = {}  # 限时排行榜 存储 {用户ID: 用户名}，确保映射关系
var limited_completed_count: int = 0  # 限时排行榜已完成查询的数量

var endless_player_ids: Array = []  # 无尽排行榜排序后的用户ID列表
var endless_id_to_name: Dictionary = {}  # 无尽排行榜 存储 {用户ID: 用户名}，确保映射关系
var endless_completed_count: int = 0  # 无尽排行榜已完成查询的数量

var current_boarder_name#当前操作的排行榜

func _ready():
	center.position.x = viewport_size.x/2 + 500
	center.position.y = viewport_size.y/2 + 130
	
	lianpu_return.position.x = viewport_size.x / 2 + 500
	lianpu_return.position.y = viewport_size.y - 60
	tab_container.visible = false
	
	# 连接信号（注意：需要确保信号能传递用户ID）
	EventBus.connect("http_fetch_request_completed", self, "_on_http_fetch_request_completed")
	# 信号应传递两个参数：用户ID和对应的用户名
	EventBus.connect("http_read_user_name_by_id_completed", self, "_on_http_read_user_name_by_id_completed")
	
	EventBus.connect("user_rank_readed",self,"_on_user_rank_readed")
	
	EventBus.connect("network_error",self,"_on_network_error")
	#默认选中LimitedTimeScore
	current_boarder_name=DataMgr.LIMITED_BOARDER
	DataMgr.fetch_leaderboarder_player("LimitedTimeScore")


func show_rank_limited():
	#显示本地玩家信息
	local_player_name.text="我的昵称:"+DataMgr.get_setting("user","nick_name")
	var highest_limited_score=DataMgr.get_setting("user","highest_limited_score")
	local_player_score.text="我的最高分:"+str(highest_limited_score)
	
	limited_rank_label.text="排名\n\n"
	limited_name_label.text="昵称\n\n"
	limited_score_label.text="得分\n\n"
	for i in range(limited_player_ids.size()):  # 注意：用 limited_player_ids 而非 player_names，确保与排名顺序一致
		var user_id = limited_player_ids[i]
		var current_player_name = limited_id_to_name.get(user_id, "未知用户")
		var score = rank_limited_dic[user_id].get("score", 0)
		limited_rank_label.text += "%d\n" % (i+1)
		limited_name_label.text += "%s\n" % current_player_name
		limited_score_label.text += "%d\n" % score
	tab_container.visible = true

func show_rank_endless():
	#显示本地玩家信息
	local_player_name.text="我的昵称:"+DataMgr.get_setting("user","nick_name")
	var highest_endless_score=DataMgr.get_setting("user","highest_endless_score")
	local_player_score.text="我的最高分:"+str(highest_endless_score)
	
	endless_rank_label.text="排名\n\n"
	endless_name_label.text="昵称\n\n"
	endless_score_label.text="得分\n\n"
	for i in range(endless_player_ids.size()):  # 注意：用 endless_player_ids 而非 player_names，确保与排名顺序一致
		var user_id = endless_player_ids[i]
		var current_player_name = endless_id_to_name.get(user_id, "未知用户")
		var score = rank_endless_dic[user_id].get("score", 0)
		endless_rank_label.text += "%d\n" % (i+1)
		endless_name_label.text += "%s\n" % current_player_name
		endless_score_label.text += "%d\n" % score
	tab_container.visible = true


func _on_http_fetch_request_completed(result):
	if current_boarder_name==DataMgr.LIMITED_BOARDER:
		DebugUtils.log("_on_http_fetch_request_completed_limited:LeaderBoarder")
		rank_limited_dic = DataMgr.rank_limited_dic
		print("rank_limited_dic 数据量：", rank_limited_dic.size())  # 新增
		if !rank_limited_dic.empty():
			DataMgr.read_user_rank_by_id(DataMgr.get_setting("user","user_id"))
			limited_player_ids = rank_limited_dic.keys()
			limited_id_to_name.clear()
			limited_completed_count = 0
			print("需要查询的用户ID数量：", limited_player_ids.size())  # 新增
			limited_player_ids.sort_custom(self, "sort_rule_limited")
			for user_id in limited_player_ids:
				DataMgr.read_user_name_by_id(user_id)
		else:
			# 如果无数据，也显示排行榜（避免一直隐藏）
			show_rank_limited()
	elif current_boarder_name==DataMgr.ENDLESS_BOARDER:
		DebugUtils.log("_on_http_fetch_request_completed_endless:LeaderBoarder")
		rank_endless_dic = DataMgr.rank_endless_dic
		print("rank_endless_dic 数据量：", rank_endless_dic.size())  # 新增
		if !rank_endless_dic.empty():
			DataMgr.read_user_rank_by_id(DataMgr.get_setting("user","user_id"))
			endless_player_ids = rank_endless_dic.keys()
			endless_id_to_name.clear()
			endless_completed_count = 0
			print("需要查询的用户ID数量：", endless_player_ids.size())  # 新增
			endless_player_ids.sort_custom(self, "sort_rule_endless")
			for user_id in endless_player_ids:
				DataMgr.read_user_name_by_id(user_id)
		else:
			# 如果无数据，也显示排行榜（避免一直隐藏）
			show_rank_endless()


func _on_http_read_user_name_by_id_completed(user_id, username):
	if current_boarder_name==DataMgr.LIMITED_BOARDER:
		#print("收到用户ID：", user_id, " 的用户名：", username)  # 新增
		limited_id_to_name[user_id] = username
		limited_completed_count += 1
		#print("当前完成数量：", completed_count, "/", player_ids.size())  # 新增
		if limited_completed_count == limited_player_ids.size():
			show_rank_limited()
	elif current_boarder_name==DataMgr.ENDLESS_BOARDER:
		#print("收到用户ID：", user_id, " 的用户名：", username)  # 新增
		endless_id_to_name[user_id] = username
		endless_completed_count += 1
		#print("当前完成数量：", completed_count, "/", player_ids.size())  # 新增
		if endless_completed_count == endless_player_ids.size():
			show_rank_endless()

func _on_user_rank_readed(result):
	if current_boarder_name==DataMgr.LIMITED_BOARDER:
		# 限时榜排名
		var limited_rank = result[DataMgr.LIMITED_BOARDER]
		print("limited_rank:",limited_rank)
		if limited_rank != -1:
			DataMgr.set_setting("user","rank_limited",limited_rank)
			local_player_rank.text="我的排名:"+str(int(limited_rank))
		else:
			DataMgr.set_setting("user","rank_limited",-1)
			local_player_rank.text="我的排名:未上榜"
	elif current_boarder_name==DataMgr.ENDLESS_BOARDER:
		# 无尽榜排名
		var endless_rank = result[DataMgr.ENDLESS_BOARDER]
		print("endless_rank:",endless_rank)
		if endless_rank != -1:
			DataMgr.set_setting("user","rank_endless",endless_rank)
			local_player_rank.text="我的排名:"+str(int(endless_rank))
		else:
			DataMgr.set_setting("user","rank_endless",-1)
			local_player_rank.text="我的排名:未上榜"

		
# 排序规则：按分数从高到低（假设分数存储在字典的 "score" 键中）
func sort_rule_limited(a, b):
	# 从字典中提取具体的分数值（根据实际键名修改 "score"）
	var score_a = rank_limited_dic[a].get("score", 0)  # 替换 "score" 为实际键名
	var score_b = rank_limited_dic[b].get("score", 0)
	return score_a > score_b
# 排序规则：按分数从高到低（假设分数存储在字典的 "score" 键中）
func sort_rule_endless(a, b):
	# 从字典中提取具体的分数值（根据实际键名修改 "score"）
	var score_a = rank_endless_dic[a].get("score", 0)  # 替换 "score" 为实际键名
	var score_b = rank_endless_dic[b].get("score", 0)
	return score_a > score_b

func _on_TabContainer_tab_selected(tab):
	if tab==0:
		current_boarder_name=DataMgr.LIMITED_BOARDER
		DataMgr.fetch_leaderboarder_player("LimitedTimeScore")
	elif tab==1:
		current_boarder_name=DataMgr.ENDLESS_BOARDER		
		DataMgr.fetch_leaderboarder_player("EndlessTimeScore")

func _on_network_error(error_msg):
	$PopupDialog/Label.text=error_msg
	$PopupDialog.popup()
