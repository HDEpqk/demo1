extends "res://scripts/tutorial/levels/level.gd"


const LEVEL_4_0=preload("res://video/三连击生火演示.webm")
const LEVEL_4_1=preload("res://video/三连不同脸谱生土演示.webm")
const LEVEL_4_2=preload("res://video/五行积攒水.webm")
const LEVEL_4_3=preload("res://video/木保护防止一次危险区域伤害.webm")

onready var teaching_display=$TeachingDisplay
#onready var lianpu1=$TutorialLianpuLevel4
#onready var lianpu2=$TutorialLianpuLevel4_1
#onready var lianpu3=$TutorialLianpuLevel4_2
#onready var danger_fire_lianpu=$TutorialDangerFire

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

var mu_protect_count:=0

var last_label:String
#onready var viewport_size = get_viewport().size
func _ready():
	._ready()
	var platform=OS.get_name()
	var text:String
	if platform == "Android" or platform == "iOS":
		text="五行积攒：\n\t\t暂时没使用的五行可以积攒起来，后续通过触碰对应元素图片使用，使用之后会减少积攒的次数。"
	else:
		text="五行积攒：\n\t\t暂时没使用的五行可以积攒起来，后续通过相应按键（Q金W木E水R火T土）或者鼠标点击对应元素图片使用，使用之后会减少积攒的次数。"
	var list=[
		{"video":LEVEL_4_0,
		"text":"生五行：\n\t\t玩家通过三连击消灭相同五行属性的脸谱可以生金木水火，连击间隔要在1s内。"},
		{"video":LEVEL_4_1,
		"text":"生五行：\n\t\t三连击消灭不同五行属性的脸谱可以生土。"},
		{"video":LEVEL_4_2,
		"text":text},
		{"video":LEVEL_4_3,"text":"木保护：\n\t\t当中心太极状态为木时，可以防止一次危险区域伤害或者÷0危险。"}
	]
	teaching_display.init_video(list)

	
	EventBus.connect("global_taiji_mode_changed",self,"_on_global_taiji_mode_changed")
	EventBus.connect("use_wuxing",self,"_on_use_wuxing")
	EventBus.connect("wuxing_generation",self,"_on_wuxing_generation")
	#订阅消灭脸谱事件
	EventBus.connect("kill_lianpu_award",self,"_on_kill_lianpu_award")
	#订阅木保护关闭的事件
	EventBus.connect("mu_protect_close",self,"_on_mu_protect_close")
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
	if mu_count >=1 and huo_count>=1 and tu_count>=1 \
	and mu_protect_count >=1 and use_huo_count>=1:
		if DataMgr.get_setting("tutorial","is_passed_level_4")==false:
			DataMgr.set_setting("tutorial","is_passed_level_4",true)
		$PassedLevel.visible=true
	
func show_pass_condition():
	var condition_label=$TeachingDisplay.get_node("PassLevelConditionLabel")
	var text="过关条件：\n1.五行生火（%d/1）\n2.五行生土（%d/1）\n3.五行生木（%d/1）" \
	% [huo_count,tu_count,mu_count] \
	+ "\n4.切换到火并划过一个脸谱（%d/1）\n5.在五行生木后划过危险火区域触发木保护（%d/1）"\
	% [use_huo_count,mu_protect_count]
	condition_label.set_text(text)
	
	#当前label和上次label不一致时才产生动画效果
	if last_label==condition_label.text:return
	
	last_label=condition_label.text
	var tween = condition_label.get_node("Tween")
	tween.interpolate_property(condition_label, "rect_scale",
	Vector2(1.1, 1.1), Vector2(1, 1), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
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

func _on_mu_protect_close(value):
	mu_protect_count+=1
	check_is_passed_level()
