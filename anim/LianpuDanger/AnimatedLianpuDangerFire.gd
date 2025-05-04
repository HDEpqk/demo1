extends AnimatedSprite

# 要循环播放的起始帧索引
var start_frame = 5
# 要循环播放的结束帧索引
var end_frame = 8

func _ready():
	# 播放动画
	play()
	# 连接帧变化信号
	connect("frame_changed", self, "_on_AnimatedSprite_frame_changed")

func _on_AnimatedSprite_frame_changed():
	# 若当前帧超过结束帧，则将帧设置为起始帧
	if frame >= end_frame:
		frame = start_frame    
