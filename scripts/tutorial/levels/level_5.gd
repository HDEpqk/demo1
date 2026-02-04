extends "res://scripts/tutorial/levels/level.gd"


const LEVEL_5_0=preload("res://video/水生木.webm")
const LEVEL_5_1=preload("res://video/水被金生.webm")
const LEVEL_5_2=preload("res://video/火克危险金.webm")
const LEVEL_5_3=preload("res://video/火被水克.webm")

onready var teaching_display=$TeachingDisplay
#onready var lianpu1=$TutorialLianpuLevel5
#onready var lianpu2=$TutorialLianpuLevel5_1
#onready var lianpu3=$TutorialLianpuLevel5_2



#玩家生脸谱
var player_jin_born_lianpu_shui:=0
var player_mu_born_lianpu_huo:=0
var player_shui_born_lianpu_mu:=0
var player_tu_born_lianpu_jin:=0
#脸谱生玩家
var lianpu_jin_born_player_shui:=0
var lianpu_mu_born_player_huo:=0
var lianpu_shui_born_player_mu:=0
var lianpu_huo_born_player_tu:=0

#玩家克脸谱
var player_jin_counter_lianpu_mu:=0
var player_shui_counter_lianpu_huo:=0
var player_huo_counter_lianpu_jin:=0
var player_tu_counter_lianpu_shui:=0
#脸谱克玩家
var lianpu_jin_counter_player_mu:=0
var lianpu_mu_counter_player_tu:=0
var lianpu_shui_counter_player_huo:=0
var lianpu_huo_counter_player_jin:=0

#onready var viewport_size = get_viewport().size

var last_label:String
func _ready():
	._ready()

	var list=[
		{"video":LEVEL_5_0,
		"text":"玩家生脸谱：\n\t\t当玩家五行和脸谱满足相生条件，在划过脸谱后会生成一个同样类型的脸谱，如视频的水生木。"},
		{"video":LEVEL_5_1,
		"text":"脸谱生玩家：\n\t\t当脸谱和玩家五行满足相生条件，在划过脸谱后会增加玩家相应五行积攒次数，如视频的水被金生。"},
		{"video":LEVEL_5_2,
		"text":"玩家克脸谱：\n\t\t当玩家五行和脸谱满足相克条件，可以无视危险区域消灭脸谱，并且触发克制奖励加分，如视频的火克金。"},
		{"video":LEVEL_5_3,
		"text":"脸谱克玩家：\n\t\t当脸谱和玩家五行满足相克条件，在划过脸谱时玩家会受伤，并且触发被克制惩罚减分，如视频的火被水克。"}
	]

	teaching_display.init_video(list)

	
	EventBus.connect("global_taiji_mode_changed",self,"_on_global_taiji_mode_changed")
	EventBus.connect("use_wuxing",self,"_on_use_wuxing")

	#订阅克制事件
	EventBus.connect("counter",self,"_on_counter")
	#订阅被克制事件
	EventBus.connect("anti_counter",self,"_on_anti_counter")
	#订阅玩家生脸谱事件
	EventBus.connect("wuxing_generation_available",self,"_on_wuxing_generation_available")
	#订阅脸谱生玩家事件
	EventBus.connect("anti_wuxing_generation",self,"_on_anti_wuxing_generation")
	
	show_pass_condition()




	
	
func check_is_passed_level():
	show_pass_condition()
	
	if player_shui_born_lianpu_mu >=1 and lianpu_jin_born_player_shui >=1 \
	and player_huo_counter_lianpu_jin >=1 and lianpu_shui_counter_player_huo >=1:
		if DataMgr.get_setting("tutorial","is_passed_level_5")==false:
			DataMgr.set_setting("tutorial","is_passed_level_5",true)
		$PassedLevel.visible=true
	
func show_pass_condition():
	var condition_label=$TeachingDisplay.get_node("PassLevelConditionLabel")
	var text="过关条件：\n1.玩家生脸谱：水生木（%d/1）" % [player_shui_born_lianpu_mu]\
	+ "\n2.玩家被脸谱生：水被金生（%d/1）"% [lianpu_jin_born_player_shui]\
	+ "\n3.玩家克脸谱：火克金（%d/1）"% [player_huo_counter_lianpu_jin]\
	+ "\n4.玩家被脸谱克：火被水克（%d/1）"% [lianpu_shui_counter_player_huo]
	condition_label.set_text(text)

	#当前label和上次label不一致时才产生动画效果
	if last_label==condition_label.text:return
	
	last_label=condition_label.text
	var tween = condition_label.get_node("Tween")
	tween.interpolate_property(condition_label, "rect_scale",
	Vector2(1.1, 1.1), Vector2(1, 1), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func _on_wuxing_generation_available(lianpu_data):
	var player_taiji_mode=lianpu_data["player_mode"]
	match player_taiji_mode:
		GameEnums.TaijiMode.jin:
			player_jin_born_lianpu_shui+=1
		GameEnums.TaijiMode.mu:
			player_mu_born_lianpu_huo+=1
		GameEnums.TaijiMode.shui:
			player_shui_born_lianpu_mu+=1
		GameEnums.TaijiMode.tu:
			player_tu_born_lianpu_jin+=1
	check_is_passed_level()

func _on_anti_wuxing_generation(player_taiji_mode):
	match player_taiji_mode:
		GameEnums.TaijiMode.mu:
			lianpu_shui_born_player_mu+=1
		GameEnums.TaijiMode.huo:
			lianpu_mu_born_player_huo+=1
		GameEnums.TaijiMode.shui:
			lianpu_jin_born_player_shui+=1
		GameEnums.TaijiMode.tu:
			lianpu_huo_born_player_tu+=1
	check_is_passed_level()

func _on_counter(player_taiji_mode,counter_score):
	match player_taiji_mode:
		GameEnums.TaijiMode.jin:
			player_jin_counter_lianpu_mu+=1
		GameEnums.TaijiMode.shui:
			player_shui_counter_lianpu_huo+=1
		GameEnums.TaijiMode.huo:
			player_huo_counter_lianpu_jin+=1
		GameEnums.TaijiMode.tu:
			player_tu_counter_lianpu_shui+=1
	check_is_passed_level()

func _on_anti_counter(player_taiji_mode,anti_counter_score):
	match player_taiji_mode:
		GameEnums.TaijiMode.jin:
			lianpu_huo_counter_player_jin+=1
		GameEnums.TaijiMode.mu:
			lianpu_jin_counter_player_mu+=1
		GameEnums.TaijiMode.huo:
			lianpu_shui_counter_player_huo+=1
		GameEnums.TaijiMode.tu:
			lianpu_mu_counter_player_tu+=1
	check_is_passed_level()
