extends Node2D

func _ready():
	var viewport_size = get_viewport().size
	#	#设置背景的缩放
#	var texture_size = $BG.get_size()
#	var scale_x = viewport_size.x / texture_size.x
#	var scale_y = viewport_size.y / texture_size.y
#	$BG.rect_scale = Vector2(scale_x, scale_y)
	#设置场景脸谱的位置
	$LianpuGameOver.position=viewport_size/2
	#设置center的位置
	$Center.position.x=viewport_size.x/2
	$Center.position.y=viewport_size.y-100

	var highest_score=DataMgr.get_setting("game","highest_score")
	if Global.score>highest_score:
		DataMgr.set_setting("game","highest_score",Global.score)
	
	$CanvasLayer/HighestScoreLabel.text="历史最高得分:"+str(DataMgr.get_setting("game","highest_score"))
	$CanvasLayer/CurrentScoreLabel.text="本局得分:"+str(Global.score)
