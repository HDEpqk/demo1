extends Node2D


#限时相关
onready var rank_limited_dic:Dictionary={}


func _ready():
	var viewport_size = get_viewport().size
	#设置场景脸谱的位置
	$LianpuGameOver.position=viewport_size/2
	#设置上传分数脸谱的位置
#	$LianpuUploadScore.position.x=viewport_size.x/2
#	$LianpuUploadScore.position.y=viewport_size.y/2+280
	
	#设置center的位置
	$Center.position.x=viewport_size.x/2
	$Center.position.y=viewport_size.y/2+130
	
	#UI显示
	var highest_score=DataMgr.get_setting("user","highest_score")
	$CanvasLayer/HighestScoreLabel.text="历史最高得分:"+str(DataMgr.get_setting("user","highest_score"))
	$CanvasLayer/CurrentScoreLabel.text="本局得分:"+str(Global.score)
	$CanvasLayer/EndReasonLabel.text="死因:"+str(SceneMgr.scene_info)
	
	#http相关
	EventBus.connect("http_fetch_request_completed",self,"_on_http_fetch_request_completed")
	EventBus.connect("http_create_user_completed",self,"_on_http_create_user_completed")
		
	if Global.score>highest_score:
		DataMgr.set_setting("user","highest_score",Global.score)
		#第1版设计：获取榜上的最低分，判断当前分数是否能上榜
#		if SceneMgr.game_scene_name=="LimitedGame":
#			DataMgr.fetch_leaderboarder_player(DataMgr.LIMITED_BOARDER)
#		elif SceneMgr.game_scene_name=="EndlessGame":
#			DataMgr.fetch_leaderboarder_player(DataMgr.ENDLESS_BOARDER)
		#第2版设计：直接上榜
		if SceneMgr.game_scene_name=="LimitedGame":
			DataMgr.update_leaderboarder_player(DataMgr.LIMITED_BOARDER)
		elif SceneMgr.game_scene_name=="EndlessGame":
			DataMgr.update_leaderboarder_player(DataMgr.ENDLESS_BOARDER)

func _enter_tree():
	EventBus.fire_event_2param("global_taiji_mode_changed",Global.taiji_mode,Global.taiji_mode)

func _on_http_fetch_request_completed(result):
#	DebugUtils.log("_on_http_fetch_request_completed:GameOverScene")
#	rank_limited_dic=DataMgr.rank_limited_dic
#	if !rank_limited_dic.empty():
#			var player_ids:=rank_limited_dic.keys()
#			player_ids.sort_custom(self,"sort_rule")
#			var last_player_id=player_ids[-1]
#			var last_player_score=rank_limited_dic[last_player_id]
#			#排行榜不足最大人数，添加user
#			if rank_limited_dic.size()<DataMgr.LEADER_BOARDER_MAX_NUM:
#				DataMgr.create_user()
#			#排行榜大于等于11个，判断分数
#			#如果当前分数大于排行榜上最后一名分数就删除最后一名,新添加一名
#			elif last_player_score<Global.score:
#				DataMgr.delete_leaderboarder_player(DataMgr.LIMITED_BOARDER,last_player_id)
#				DataMgr.update_leaderboarder_player(DataMgr.LIMITED_BOARDER)
	DebugUtils.log("_on_http_fetch_request_completed:GameOverScene")

func _on_http_create_user_completed(result):
	DebugUtils.log("_on_http_create_user_completed:GameOverScene")
	#DataMgr.update_leaderboarder_player(DataMgr.LIMITED_BOARDER)



func sort_rule(a,b):return rank_limited_dic[a]>rank_limited_dic[b]


