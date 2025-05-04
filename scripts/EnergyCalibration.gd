extends Control 

# 配置参数
export var value_range: Vector2 = Vector2(-1.1, 1.1)  # 值范围（左到右）
export var bg_width: float = 400.0  # 背景条宽度（需与实际尺寸一致）
export var pointer_max_offset: float = 200.0  # 指针最大左右偏移（背景条宽度的一半）
export var total_time: int = 20  # 总倒计时秒数

var current_value: float = 0.0  # 当前值（初始为 0，对应中间位置）
var half_bg_width: float =bg_width/2
var is_timming:bool=false
var current_time: int
var temp_energy:float=0#临时能量值
onready var global_script = get_node("/root/Global")  # 假设单例名为 Global

func _ready():
	$BG/pointer/Label.text=str(global_script.energy)
	current_time = total_time
	$BG/CountdownLabel.visible=false
	$CountdownTimer.wait_time = 1.0  # 每秒触发一次


func set_value(new_value: float):
	if new_value>0:
		if global_script.max_energy!=0:
			new_value/=global_script.max_energy
	elif new_value<0:
		if abs(global_script.min_energy)!=0:
			new_value/=abs(global_script.min_energy)
	# 限制值在范围内
	current_value = clamp(new_value, value_range.x, value_range.y)
	var offset:float=0
	# 映射值到偏移量（例如：-1 → 左边界，1 → 右边界，0 → 中心）
	if current_value>0:
		if current_value>1:
			offset=(bg_width-half_bg_width)
		else:
			offset = current_value*abs(($BG/max.rect_position.x-$BG.rect_size.x / 2))
	elif current_value<0:
		if current_value<-1:
			offset=-(bg_width-half_bg_width)
		else:
			offset = current_value*abs($BG.rect_size.x / 2-$BG/min.rect_position.x)
		
	# 更新指针位置（锚点已设为底部中心，x 为偏移量）
	$BG/pointer.rect_position.x = half_bg_width + offset
	#更新energytext
	var formatted = "%0.1f" % global_script.energy
	# 处理负零问题
	if formatted.begins_with("-0"):
		formatted = formatted.replace("-", "")
	$BG/pointer/Label.text=formatted.replace(".0", "")
	check_energy()

func check_energy():
	#检查能量处于什么范围
	if global_script.energy>global_script.max_energy or global_script.energy<global_script.min_energy:
		if !is_timming:
			#显示倒计时文本
			$BG/CountdownLabel.visible=true
			update_display()
			#开启计时器
			$CountdownTimer.start()
			is_timming=!is_timming
			temp_energy=global_script.energy
		else:
			if abs(global_script.energy)>abs(temp_energy):
				temp_energy=global_script.energy
#	elif Global.energy<Global.min_energy:
#		if !is_timming:
#			#显示倒计时文本
#			$BG/CountdownLabel.visible=true
#			update_display()
#			#开启计时器
#			$CountdownTimer.start()
#			is_timming=!is_timming
#			if Global.energy<temp_energy:
#				temp_energy=Global.energy
	else:
		if is_timming:
			#关闭倒计时文本
			$BG/CountdownLabel.visible=false
			#关闭计时器
			$CountdownTimer.stop()
			is_timming=!is_timming
			current_time = total_time
			if temp_energy<0:
				global_script.min_energy=temp_energy
				$BG/min.text=str(float("%0.1f" % global_script.min_energy))
			elif temp_energy>0:
				global_script.max_energy=temp_energy
				$BG/max.text=str(float("%0.1f" % global_script.max_energy))
	print("check_energy:temp_energy=",temp_energy)
	print("check_energy:min_energy=",global_script.min_energy)
	print("check_energy:max_energy=",global_script.max_energy)
	
		
# 计时器信号回调
func _on_CountdownTimer_timeout():
	current_time -= 1
	update_display()
	if current_time <= 0:
		$CountdownTimer.stop()
		$BG/CountdownLabel.text = "TIME UP!"
		#跳转到结束界面
		get_tree().change_scene("res://scene/GameOverScene.tscn")

# 更新显示（保持缩进统一用4个空格）
func update_display():
	$BG/CountdownLabel.text = "%d" % current_time



