extends Node2D


#限时相关
#onready var rank_limited_dic:Dictionary={}


func _ready():
	$UserRegister.visible=false
	var viewport_size = get_viewport().size
	#设置场景脸谱的位置
	$LianpuGameOver.position=viewport_size/2
	#设置上传分数脸谱的位置
	$LianpuUploadScore.position.x=viewport_size.x/2
	$LianpuUploadScore.position.y=viewport_size.y/2+280
	#设置确认注册对话框的位置
	$ConfirmRegister.rect_position=viewport_size/2
	$ConfirmRegister.dialog_text="上传分数需要注册用户，立即注册？"
	#设置确认上传对话框的位置
	$ConfirmBeforeUpload.rect_position=viewport_size/2
	$ConfirmBeforeUpload.dialog_text="上传本局分数会覆盖上次上传分数，立即上传？"
	
	#设置用户注册面板的位置
	$UserRegister.rect_position=viewport_size/2
	#设置center的位置
	$Center.position.x=viewport_size.x/2
	$Center.position.y=viewport_size.y/2+130
	var highest_limited_score
	var highest_endless_score
	#UI显示
	if SceneMgr.game_scene_name=="LimitedGame":
		highest_limited_score=DataMgr.get_setting("user","highest_limited_score")
		$CanvasLayer/HighestScoreLabel.text="限时挑战最高得分:"+str(highest_limited_score)
		if Global.score>highest_limited_score:
			DataMgr.set_setting("user","highest_limited_score",Global.score)
			highest_limited_score=DataMgr.get_setting("user","highest_limited_score")
			$CanvasLayer/HighestScoreLabel.text="限时挑战最高得分:"+str(highest_limited_score)
	elif SceneMgr.game_scene_name=="EndlessGame":
		highest_endless_score=DataMgr.get_setting("user","highest_endless_score")
		$CanvasLayer/HighestScoreLabel.text="无尽挑战最高得分:"+str(highest_endless_score)
		if Global.score>highest_endless_score:
			DataMgr.set_setting("user","highest_endless_score",Global.score)
			highest_endless_score=DataMgr.get_setting("user","highest_endless_score")
			$CanvasLayer/HighestScoreLabel.text="无尽挑战最高得分:"+str(highest_endless_score)
	

	$CanvasLayer/CurrentScoreLabel.text="本局得分:"+str(Global.score)
	$CanvasLayer/EndReasonLabel.text="死因:"+str(SceneMgr.scene_info)
	
	#http相关
	EventBus.connect("http_fetch_request_completed",self,"_on_http_fetch_request_completed")
	EventBus.connect("http_create_user_completed",self,"_on_http_create_user_completed")
		

		#第1版设计：获取榜上的最低分，判断当前分数是否能上榜
#		if SceneMgr.game_scene_name=="LimitedGame":
#			DataMgr.fetch_leaderboarder_player(DataMgr.LIMITED_BOARDER)
#		elif SceneMgr.game_scene_name=="EndlessGame":
#			DataMgr.fetch_leaderboarder_player(DataMgr.ENDLESS_BOARDER)
		#第2版设计：当局分大于历史最高自动直接上榜
		#第3版设计：结束界面增加上传分数lianpu，
		#如果玩家提交分数时没注册就跳出提示框提示玩家需要注册，
		#如果玩家注册了才执行上传分数逻辑，玩家每天有三次机会上传
			

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
	pass

func _on_http_create_user_completed(result):
	#DebugUtils.log("_on_http_create_user_completed:GameOverScene")
	#DataMgr.update_leaderboarder_player(DataMgr.LIMITED_BOARDER)
	pass



# 排序规则：按分数从高到低（假设分数存储在字典的 "score" 键中）
#func sort_rule(a, b):
#	# 从字典中提取具体的分数值（根据实际键名修改 "score"）
#	var score_a = rank_limited_dic[a].get("score", 0)  # 替换 "score" 为实际键名
#	var score_b = rank_limited_dic[b].get("score", 0)
#	return score_a > score_b





