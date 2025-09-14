extends "res://scripts/tutorial/levels/level.gd"


const LEVEL_4_0=preload("res://video/三连击生火演示.webm")
const LEVEL_4_1=preload("res://video/三连不同脸谱生土演示.webm")
const LEVEL_4_2=preload("res://video/五行积攒水.webm")


onready var teaching_display=$TeachingDisplay
onready var lianpu1=$TutorialLianpuLevel4
onready var lianpu2=$TutorialLianpuLevel4_1
onready var lianpu3=$TutorialLianpuLevel4_2

var jin_count:=0
var mu_count:=0
var shui_count:=0
var huo_count:=0
var tu_count:=0

var use_jin_count:=0
var use_mu_count:=0
var use_shui_count:=0
var use_huo_count:=0
var use_tu_count:=0


onready var viewport_size = get_viewport().size
func _ready():
	._ready()

	var list=[
		{"video":LEVEL_4_0,
		"text":"生五行：玩家通过三连击消灭相同五行属性(相同颜色)的脸谱可以生金木水火，连击间隔要在1s内。"},
		{"video":LEVEL_4_1,
		"text":"生五行：三连击消灭不同五行属性(不同颜色)的脸谱可以生土。"},
		{"video":LEVEL_4_2,
		"text":"五行积攒：暂时没使用的五行可以积攒起来，后续通过相应按键（Q金W木E水R火T土）直接切换使用，使用之后会减少积攒的次数。"}
	]
	teaching_display.init_video(list)
	lianpu1.position.x = viewport_size.x/2
	lianpu1.position.y = viewport_size.y/2-130
	
	lianpu2.position.x = viewport_size.x/2+130
	lianpu2.position.y = viewport_size.y/2
	
	lianpu3.position.x = viewport_size.x/2-130
	lianpu3.position.y = viewport_size.y/2
	
	
	EventBus.connect("global_taiji_mode_changed",self,"_on_global_taiji_mode_changed")
	EventBus.connect("use_wuxing",self,"_on_use_wuxing")
	EventBus.connect("wuxing_generation",self,"_on_wuxing_generation")
	#订阅消灭脸谱事件
	EventBus.connect("kill_lianpu_award",self,"_on_kill_lianpu_award")
	show_pass_condition()

func _on_global_taiji_mode_changed(new_value: int,old_value: int=0,is_new_mode:=true):
	match new_value:
		GameEnums.TaijiMode.jin:
			jin_count+=1
		GameEnums.TaijiMode.mu:
			mu_count+=1
		GameEnums.TaijiMode.shui:
			shui_count+=1
		GameEnums.TaijiMode.huo:
			huo_count+=1
		GameEnums.TaijiMode.tu:
			tu_count+=1
	check_is_passed_level()
	
	
func _on_use_wuxing(player_taiji_mode):
	print("_on_use_wuxing:level4")
	match player_taiji_mode:
		GameEnums.TaijiMode.jin:
			use_jin_count+=1
		GameEnums.TaijiMode.mu:
			use_mu_count+=1
		GameEnums.TaijiMode.shui:
			use_shui_count+=1
		GameEnums.TaijiMode.huo:
			use_huo_count+=1
		GameEnums.TaijiMode.tu:
			use_tu_count+=1
	check_is_passed_level()
	
	
func check_is_passed_level():
	show_pass_condition()
	if jin_count >=1 and mu_count >=1 and shui_count >=1 and huo_count>=1 and tu_count>=1 \
	and use_jin_count >=1 and use_mu_count >=1 and use_shui_count >=1 and use_huo_count>=1 and use_tu_count>=1:
		if DataMgr.get_setting("tutorial","is_passed_level_4")==false:
			DataMgr.set_setting("tutorial","is_passed_level_4",true)
		$PassedLevel.visible=true
	
func show_pass_condition():
	var label=$TeachingDisplay.get_node("PassLevelConditionLabel")
	label.text="过关条件：\n\n三连击相同五行属性脸谱生五行\n1.五行生金（%d/1）\n2.五行生木（%d/1）\n3.五行生水（%d/1）\n4.五行生火（%d/1）\n5.五行生土（%d/1）" \
	% [jin_count,mu_count,shui_count,huo_count,tu_count] \
	+ "\n\n使用积攒的五行\n1.按Q切换到金并划过一个脸谱（%d/1）\n2.按W切换到木并划过一个脸谱（%d/1）\n3.按E切换到水并划过一个脸谱（%d/1）\n4.按R切换到火并划过一个脸谱（%d/1）\n5.按T切换到土并划过一个脸谱（%d/1）"\
	% [use_jin_count,use_mu_count,use_shui_count,use_huo_count,use_tu_count]

func _on_wuxing_generation(lianpu_data):
	var player_taiji_mode=lianpu_data["player_mode"]
	match player_taiji_mode:
		GameEnums.TaijiMode.jin:
			use_jin_count+=1
		GameEnums.TaijiMode.mu:
			use_mu_count+=1
		GameEnums.TaijiMode.shui:
			use_shui_count+=1
		GameEnums.TaijiMode.huo:
			use_huo_count+=1
		GameEnums.TaijiMode.tu:
			use_tu_count+=1
	check_is_passed_level()

func _on_kill_lianpu_award(base_score):
	match Global.taiji_mode:
		GameEnums.TaijiMode.jin:
			use_jin_count+=1
		GameEnums.TaijiMode.mu:
			use_mu_count+=1
		GameEnums.TaijiMode.shui:
			use_shui_count+=1
		GameEnums.TaijiMode.huo:
			use_huo_count+=1
		GameEnums.TaijiMode.tu:
			use_tu_count+=1
	check_is_passed_level()
