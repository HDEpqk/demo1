extends "res://scripts/tutorial/levels/level.gd"


const LEVEL_3_0=preload("res://video/能量计算演示.webm")
const LEVEL_3_1=preload("res://video/玩家能量值超过区间触发倒计时.webm")

onready var teaching_display=$TeachingDisplay
#onready var lianpu=$TutorialLianpuLevel3
#onready var viewport_size = get_viewport().size
func _ready():
	._ready()

	var list=[
		{"video":LEVEL_3_0,"text":"能量计算：\n\t\t脸谱死亡后，上方能量条能量会根据脸谱的计算符号和能量值进行计算，如视频黄色脸谱碰到中心死亡后上方能量条1-7变成-6，消灭了一个×3的绿色脸谱后-6×3变成-18。"},
		{"video":LEVEL_3_1,"text":"能量区间：\n\t\t上方能量值超过区间[-10,10]后，会触发20s倒计时。10s到20s，游戏得分倍数×2，最后10s游戏得分倍数×4，当倒计时结束时游戏结束。"}
	]
	teaching_display.init_video(list)
#	lianpu.position.x = viewport_size.x/2
#	lianpu.position.y = viewport_size.y/2+130
	#绑定游戏结束事件
	EventBus.connect_event("game_over",self,"_on_game_over")
	

func _on_game_over(info):
	get_tree().reload_current_scene()
