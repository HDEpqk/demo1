extends RichTextLabel

#const GAIN_SCORE_SFX=preload("res://audio/sfx/gain_score.wav")
#onready var audio_player=$AudioStreamPlayer
# 目标分数（最终要显示的分数）
var target_score = 0
# 当前显示的分数
var current_score = 0
# 动画速度（值越大，增加越快）
export var speed = 40.0

func _ready():
	# 初始化显示
	bbcode_text ="得分:%.0f" % current_score

func _process(delta):
	if abs(current_score-target_score)<=0.1:
		# 更新显示
		bbcode_text ="得分:"+"[color=#ffffff]"+"%.0f" % current_score+"[/color]"

	# 如果当前分数不等于目标分数，进行平滑过渡
	elif current_score < target_score:
		var temp=current_score
		# 使用线性插值让分数逐渐接近目标值
		current_score = lerp(current_score, target_score, delta * speed)
		
		# 更新显示
		bbcode_text ="得分:"+"[color=#e40000]"+"%.0f" % current_score+"[/color]"
		#audio_player.stream=GAIN_SCORE_SFX
		#audio_player.play()

	elif current_score > target_score:
		# 使用线性插值让分数逐渐接近目标值
		current_score = lerp(current_score, target_score, delta * speed)
		# 更新显示
		bbcode_text ="得分:"+"[color=#2d93dd]"+"%.0f" % current_score+"[/color]"
		#audio_player.stream=GAIN_SCORE_SFX
		#audio_player.play()

# 设置目标分数（外部调用此方法来更新分数）
func set_score(new_score):
	# 确保新分数为正数
	target_score = max(0, new_score)

# 增加分数（外部调用此方法来增加分数）
func add_score(amount):
	target_score = max(0, target_score + amount)


	
