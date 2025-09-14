extends "res://scripts/tutorial/levels/level.gd"


const LEVEL_2_0=preload("res://video/阴死.webm")
const LEVEL_2_1=preload("res://video/阳生.webm")
onready var teaching_display=$TeachingDisplay
onready var lianpu=$TutorialLianpuNormal
onready var viewport_size = get_viewport().size
func _ready():
	._ready()

	var list=[
		{"video":LEVEL_2_0,"text":"阴死：在阴状态下，玩家可以划过脸谱让脸谱死亡，死亡伴随着能量计算。"},
		{"video":LEVEL_2_1,"text":"阳生：在阳状态下，玩家可以划过脸谱实现变脸，让脸谱像重获新生一样。"}
	]
	teaching_display.init_video(list)
	lianpu.position.x = viewport_size.x/2
	lianpu.position.y = viewport_size.y/2+130

