extends "res://scripts/tutorial/levels/level.gd"

#videos
const LEVEL_7_0_VIDEO=preload("res://video/阴死.webm")
const LEVEL_7_1_VIDEO=preload("res://video/危险水脸谱无法被阴主动消灭.webm")
const LEVEL_7_2_VIDEO=preload("res://video/疯狂时间.webm")
const LEVEL_7_3_VIDEO=preload("res://video/隐身脸谱碰到阴状态太极.webm")

#texts
const LEVEL_7_0_TEXT="[center]普通脸谱[/center]\n\n普通属性：\n\t\t计算符号是加减乘除，能参与能量计算和五行相生相克。"
const LEVEL_7_1_TEXT="[center]危险脸谱[/center]\n\n普通属性：\n\t\t同普通脸谱。\n\n特殊属性：\n\t\t1.用土状态划过危险水脸谱或其碰到中心太极时才能消灭该脸谱，其他状态划过会触发水之闪避。"+\
		"\n\t\t2.水之闪避：危险水脸谱不会被消灭，也不会参与能量计算，但是可以参与连击。\n\t\t3.划过危险金木火脸谱的危险区域或它们的危险区域碰到中心太极时都会受伤。"
const LEVEL_7_2_TEXT="[center]道具脸谱[/center]\n\n普通属性：\n\t\t同普通脸谱。\n\n特殊属性：\n\t\t1.白底道具脸谱不会变脸，不会被阳状态的中心太极消灭。\n\t\t2.消灭道具火脸谱会加快所有脸谱的生成。"+\
		"\n\t\t3.消灭道具水脸谱会减慢所有脸谱的生成。\n\t\t4.消灭道具木脸谱会全局得分倍数加倍。"+\
		"\n\t\t5.消灭道具金脸谱会进入疯狂8秒，在此期间脸谱加速生成，得分加倍，玩家可以暂停能量倒计时，无视危险区域，无视被克制风险，无视能量计算，无视一切去消灭脸谱。"
const LEVEL_7_3_TEXT="[center]隐身脸谱[/center]\n\n普通属性：\n\t\t同普通脸谱。\n\n特殊属性：\n\t\t1.黑底隐身脸谱不会被阴状态消灭（包括阴状态的中心太极）。\n\t\t2.该脸谱每隔5s会隐身5s。"



onready var teaching_display=$TeachingDisplay

#onready var viewport_size = get_viewport().size
func _ready():
	._ready()

	var list=[
		{"video":LEVEL_7_0_VIDEO,
		"text":LEVEL_7_0_TEXT},
		{"video":LEVEL_7_1_VIDEO,
		"text":LEVEL_7_1_TEXT},
		{"video":LEVEL_7_2_VIDEO,
		"text":LEVEL_7_2_TEXT},
		{"video":LEVEL_7_3_VIDEO,
		"text":LEVEL_7_3_TEXT}
	]
	teaching_display.init_video(list)
#	var panel=$TeachingDisplay.get_node("Panel")
#	if panel != null:
#		panel.show()

	

