extends "res://scripts/game_play/Lianpu.gd"



#hide相关
var hide_timer:Timer
var hide_time:float=5
var is_hiding:bool=false
var tween:Tween


		
func _ready():
	._ready()
	#获取所有死亡动画的名称
#	for anim in $AnimationPlayer.get_animation_list():
#		if anim.begins_with("death_"):
#			death_animations.append(anim)
	#设置对象属于第2层
	collision_layer =1<<1
	# 设置对象检测第1层和第4层
	collision_mask = 1 | (1<<3)
	#初始化hide_timer
	hide_timer=get_node("HideTimer")
	if hide_timer!=null:
		hide_timer.set_wait_time(hide_time)
		hide_timer.connect("timeout",self,"_on_hidetimer_timeout")
		hide_timer.start()
	else:
		push_warning("未找到hide_timer")
	#初始化tween
	tween = get_node("Tween")
	if tween==null:
		push_warning("未找到tween")


func init(_mode:int, pos:Vector2, _reward_score:float, _speed:float):
	.init(_mode, pos, _reward_score, _speed)
	#初始能量值
	var	random = RandomNumberGenerator.new()
	random.randomize()
	energy=random.randi_range(0,10)
	DebugUtils.log("初始能量："+str(energy))
	update_energy_label()
	#开启碰撞体
	$BodyCollision.set("disabled", false)
	$Sprite.visible=true

func handle_death():
	#关闭碰撞体和图片
	$BodyCollision.set("disabled", true)
	$Sprite.visible=false
	.handle_death()

func _on_hidetimer_timeout():
	handle_hide()

func handle_hide():
	if !is_hiding:
		fade_out(self)
		is_hiding=true
	else:
		fade_in(self)
		is_hiding=false
# 淡入效果（显示）
func fade_in(object: CanvasItem, duration: float = 0.5):
	if tween==null: return
	object.show()  # 确保对象可见
	tween.interpolate_property(object, "modulate:a",
		object.modulate.a,  # 当前透明度
		1.0,               # 目标透明度（完全不透明）
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()
	yield(tween, "tween_completed")

# 淡出效果（隐藏）
func fade_out(object: CanvasItem, duration: float = 0.5):
	if tween==null: return
	tween.interpolate_property(object, "modulate:a",
		object.modulate.a,  # 当前透明度
		0.0,               # 目标透明度（完全透明）
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	
	tween.start()
	yield(tween, "tween_completed")
	object.hide()  # 动画完成后隐藏
