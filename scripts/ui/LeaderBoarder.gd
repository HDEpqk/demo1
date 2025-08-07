extends CanvasLayer

onready var lianpu_return= $LianpuReturn
onready var center = $Center
onready var viewport_size = get_viewport().size

#限时相关
onready var rank_limited_dic:Dictionary={}
onready var tab_container=$"TabContainer"
onready var limited_rank_label=$"TabContainer/限时/Rank"
onready var limited_name_label=$"TabContainer/限时/Name"
onready var limited_score_label=$"TabContainer/限时/Score"

func _ready():
	center.position.x = viewport_size.x/2
	center.position.y = viewport_size.y/2+130
	
	lianpu_return.position.x = viewport_size.x / 2
	lianpu_return.position.y = viewport_size.y - 60
	tab_container.visible=false
	EventBus.connect("http_fetch_request_completed",self,"_on_http_fetch_request_completed")
	DataMgr.fetch_leaderboarder_player("LimitedTimeScore")


func show_rank_limited():
	tab_container.visible=true
	var player_names:=rank_limited_dic.keys()
	player_names.sort_custom(self,"sort_rule")#可能会出错
	limited_rank_label.text="排名\n\n"
	limited_name_label.text="昵称\n\n"
	limited_score_label.text="得分\n\n"
	for i in range(len(player_names)):
		var current_player_name=player_names[i]
		limited_rank_label.text+="%d\n" % (i+1)
		limited_name_label.text+="%s\n" % current_player_name
		limited_score_label.text+="%d\n" % rank_limited_dic[current_player_name]

func _on_http_fetch_request_completed(result):
	DebugUtils.log("_on_http_fetch_request_completed:LeaderBoarder")
	DebugUtils.log("http_fetch_success:LeaderBoarder")
	rank_limited_dic=DataMgr.rank_limited_dic
	if !rank_limited_dic.empty():
		show_rank_limited()

func sort_rule(a,b):return rank_limited_dic[a]>rank_limited_dic[b]
