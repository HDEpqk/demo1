extends "res://scripts/tutorial/levels/level.gd"


const LEVEL_6_0=preload("res://video/危险火脸谱危险区域碰到玩家.webm")
const LEVEL_6_1=preload("res://video/除0演示.webm")
const LEVEL_6_2=preload("res://video/能量倒计时结束.webm")
const LEVEL_6_3=preload("res://video/木保护防止一次危险区域伤害.webm")


onready var teaching_display=$TeachingDisplay
onready var lianpu_danger_fire=$TutorialDangerFire
onready var lianpu_prop_decelerate=$Tutorialprop_decelerate

onready var viewport_size = get_viewport().size

var hurt_count:=0
var game_over:=0

func _ready():
	._ready()

	var list=[
		{"video":LEVEL_6_0,"text":"受伤条件：\n1.当玩家划过危险区域或者危险区域碰到中心太极时都会受伤。\n2.当玩家五行被脸谱克制时会受伤。\n\n受伤效果：\n会暂停3s无法使用当前状态的太极。"},
		{"video":LEVEL_6_1,"text":"游戏结束条件：消灭÷0脸谱游戏结束，因为除法运算中不能÷0。"},
		{"video":LEVEL_6_2,"text":"游戏结束条件：能量超限，玩家能量条倒计时结束游戏结束。"},
		{"video":LEVEL_6_3,"text":"木保护：当中心太极状态为木时，可以防止一次危险区域伤害或者÷0危险。"}
	]
	teaching_display.init_video(list)
	lianpu_danger_fire.position.x = viewport_size.x/2-200
	lianpu_danger_fire.position.y = viewport_size.y/2-130
	
	lianpu_prop_decelerate.position.x = viewport_size.x/2+200
	lianpu_prop_decelerate.position.y = viewport_size.y/2-130
	
	#订阅player受伤的事件
	EventBus.connect("player_hurt",self,"_on_player_hurt")
	#绑定游戏结束事件
	EventBus.connect_event("game_over",self,"_on_game_over")
	show_pass_condition()


func check_is_passed_level():
	show_pass_condition()
	if hurt_count >=2 and game_over >=2:
		if DataMgr.get_setting("tutorial","is_passed_level_6")==false:
			DataMgr.set_setting("tutorial","is_passed_level_6",true)
		$PassedLevel.visible=true
	

func show_pass_condition():
	var condition_label=$TeachingDisplay.get_node("PassLevelConditionLabel")
	var text="过关条件：\n1.受伤两次（%d/2）\n2.让游戏结束两次（%d/2）" % [hurt_count,game_over]
	condition_label.set_text(text)
	var tween = condition_label.get_node("Tween")
	tween.interpolate_property(condition_label, "rect_scale",
	Vector2(1.1, 1.1), Vector2(1, 1), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
func _on_player_hurt(global_mode):
	hurt_count+=1
	check_is_passed_level()
func _on_game_over(info):
	game_over+=1
	check_is_passed_level()
