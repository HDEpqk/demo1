# SpawnManager.gd
extends Node2D

# 配置参数
export var base_spawn_interval := 3.0
export var score_acceleration := 0.98  # 每1000分时间缩短系数
export var min_spawn_interval: float = 0.3   # 最小生成间隔
#加速后的生成间隔
var accelerate_spawn_interval:=1.0
#减速后的生成间隔
var decelerate_spawn_interval:=5.0
#当前是否是加速状态
var is_accelerate:=false
#当前是否是减速状态
var is_decelerate:=false

# 敌人配置（类型、场景、最小分数、权重）
const LIANPU_CONFIG := [
	{
		"type": "normal_red",
		"scene": preload("res://scene/game_play/LianpuNormal/normal_red.tscn"),
		"min_score": 0,
		"weight": 20,
		"reward_score":1,
		"speed":15,
		"mode":GameEnums.TaijiMode.huo
	},
		{
		"type": "normal_yellow",
		"scene": preload("res://scene/game_play/LianpuNormal/normal_yellow.tscn"),
		"min_score": 0,
		"weight": 20,
		"reward_score":1,
		"speed":15,
		"mode":GameEnums.TaijiMode.jin		
	},
		{
		"type": "normal_green",
		"scene": preload("res://scene/game_play/LianpuNormal/normal_green.tscn"),
		"min_score": 0,
		"weight": 20,
		"reward_score":1,
		"speed":15,
		"mode":GameEnums.TaijiMode.mu		
	},
		{
		"type": "normal_blue",
		"scene": preload("res://scene/game_play/LianpuNormal/normal_blue.tscn"),
		"min_score": 0,
		"weight": 20,
		"reward_score":1,
		"speed":15,
		"mode":GameEnums.TaijiMode.shui
	},
	{
		"type": "danger_fire",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_fire.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 5,
		"reward_score":5,
		"speed":10,
		"mode":GameEnums.TaijiMode.huo
	},
	{
		"type": "danger_metal",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_metal.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 5,
		"reward_score":10,
		"speed":10,
		"mode":GameEnums.TaijiMode.jin
	},
	{
		"type": "danger_thorns",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_thorns.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 5,
		"reward_score":5,
		"speed":10,
		"mode":GameEnums.TaijiMode.mu
	},
	{
		"type": "danger_water",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_water.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 5,
		"reward_score":5,
		"speed":10,
		"mode":GameEnums.TaijiMode.shui
	},
	{
		"type": "prop_accelerate",
		"scene": preload("res://scene/game_play/LianpuProp/prop_accelerate.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 3,
		"reward_score":30,
		"speed":20,
		"mode":GameEnums.TaijiMode.huo
	},
	{
		"type": "prop_crazy",
		"scene": preload("res://scene/game_play/LianpuProp/prop_crazy.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 2,
		"reward_score":50,
		"speed":25,
		"mode":GameEnums.TaijiMode.jin
	},
	{
		"type": "prop_multiple",
		"scene": preload("res://scene/game_play/LianpuProp/prop_multiple.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 3,
		"reward_score":30,
		"speed":20,
		"mode":GameEnums.TaijiMode.mu
	},
	{
		"type": "prop_decelerate",
		"scene": preload("res://scene/game_play/LianpuProp/prop_decelerate.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 3,
		"reward_score":30,
		"speed":20,
		"mode":GameEnums.TaijiMode.shui
	},
	{
		"type": "hide_red",
		"scene": preload("res://scene/game_play/LianpuHide/hide_red.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 1,
		"reward_score":20,
		"speed":20,
		"mode":GameEnums.TaijiMode.huo
	},
	{
		"type": "hide_yellow",
		"scene": preload("res://scene/game_play/LianpuHide/hide_yellow.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 1,
		"reward_score":20,
		"speed":20,
		"mode":GameEnums.TaijiMode.jin
	},
	{
		"type": "hide_green",
		"scene": preload("res://scene/game_play/LianpuHide/hide_green.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 1,
		"reward_score":20,
		"speed":20,
		"mode":GameEnums.TaijiMode.mu
	},
	{
		"type": "hide_blue",
		"scene": preload("res://scene/game_play/LianpuHide/hide_blue.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 1,
		"reward_score":20,
		"speed":20,
		"mode":GameEnums.TaijiMode.shui
	}
	
]

onready var timer = $SpawnTimer
var current_score := 0
onready var lianpu_container=$SpawnedLianpus

func _ready():
	update_spawn_speed()
	EventBus.connect("global_score_changed", self, "_on_score_changed")
	EventBus.connect("cycle_lianpu", self, "_on_cycle_lianpu")
	EventBus.connect("accelerate_spawn_begin", self, "_on_accelerate_spawn_begin")
	EventBus.connect("accelerate_spawn_end", self, "_on_accelerate_spawn_end")
	EventBus.connect("decelerate_spawn_begin", self, "_on_decelerate_spawn_begin")
	EventBus.connect("decelerate_spawn_end", self, "_on_decelerate_spawn_end")
	EventBus.connect("wuxing_generation_available",self,"_on_wuxing_generation_available")
	
func _on_score_changed(new_score: int):
	current_score = new_score
	update_spawn_speed()

func update_spawn_speed():

	#DebugUtils.log("update_spawn_speed() - is_accelerate: " + str(is_accelerate) + ", is_decelerate: " + str(is_decelerate))
	# 原方法代码...
	# 根据分数加速生成：每1000分减少2%间隔时间
	var acceleration = pow(score_acceleration, floor(current_score / 1000.0))
	var current_spawn_interval= max(base_spawn_interval * acceleration, min_spawn_interval)
	if is_accelerate:
		#疯狂时间加速生成更快
		if Global.is_invincible:
			current_spawn_interval=min_spawn_interval
		else:
			current_spawn_interval=min(accelerate_spawn_interval, current_spawn_interval)
	elif is_decelerate:
		current_spawn_interval=decelerate_spawn_interval

	timer.wait_time = current_spawn_interval
	DebugUtils.log("当前生成间隔时间："+str(timer.wait_time))
	if timer.is_stopped():
		timer.start()

func _on_SpawnTimer_timeout():
	var lianpu_dic = _select_lianpu_random()
	if Global.is_invincible:
		#在疯狂时间内不再生成疯狂脸谱
		while lianpu_dic["type"]=="prop_crazy":
			lianpu_dic = _select_lianpu_random()
	var lianpu = lianpu_dic.scene.instance()
	lianpu_container.add_child(lianpu)
	
	# 初始化位置和模式和奖励分数
	var pos = _get_spawn_position()
	var mode = lianpu_dic["mode"]
	var reward_score=lianpu_dic["reward_score"]
	var speed=lianpu_dic["speed"]
	var lianpu_type=lianpu_dic["type"]
	var dic:={"mode":mode,
	"pos":pos,
	"reward_score":reward_score,
	"speed":speed,
	"lianpu_type":lianpu_type}

	if lianpu.has_method("init"):
		lianpu.init(dic)		

func _select_lianpu_random() -> Dictionary:
	# 随机筛选符合条件的脸谱
	var available = []
	for config in LIANPU_CONFIG:
		if config.min_score <= current_score:
			available.append(config)
 
	# 构建权重字典（key: 配置索引，value: 权重）
	var weight_dict = {}
	for i in range(available.size()):
		weight_dict[i] = available[i].weight
	
	# 使用工具类获取加权随机索引
	var selected_index = WeightedRandom.get_item(weight_dict)
	
	return available[selected_index]



# 新增配置参数
export var spawn_margin := 100.0    # 生成点与屏幕边缘的距离
export var active_spawn_edges := [true, true, true, true]  # [上,下,左,右]是否激活

func _get_spawn_position() -> Vector2:
	var viewport = get_viewport_rect().grow(-spawn_margin)
	var edges = []
	
	# 根据激活的边缘生成候选坐标 
	if active_spawn_edges[0]:  # 上边缘
		edges.append(Vector2(
			rand_range(viewport.position.x, viewport.end.x),
			viewport.position.y - spawn_margin
		))
	if active_spawn_edges[1]:  # 下边缘
		edges.append(Vector2(
			rand_range(viewport.position.x, viewport.end.x),
			viewport.end.y + spawn_margin
		))
	if active_spawn_edges[2]:  # 左边缘
		edges.append(Vector2(
			viewport.position.x - spawn_margin,
			rand_range(viewport.position.y, viewport.end.y)
		))
	if active_spawn_edges[3]:  # 右边缘
		edges.append(Vector2(
			viewport.end.x + spawn_margin,
			rand_range(viewport.position.y, viewport.end.y)
		))
	
	return edges[randi() % edges.size()] if !edges.empty() else Vector2.ZERO


# SpawnManager.gd lianpu切换部分
# 配置不同敌人组的循环顺序（示例新增两组）
const CYCLE_GROUPS = {
	"danger_elements": ["danger_fire", "danger_metal", "danger_thorns", "danger_water"],
	"normal_elements": ["normal_red", "normal_yellow", "normal_green","normal_blue"],
	"hide_elements":["hide_red","hide_yellow","hide_green","hide_blue"]
}

# 通用事件处理
func _on_cycle_lianpu(event_data: Dictionary):
	 # 立即消除原脸谱
	if event_data.has("origin_node"):
		event_data["origin_node"].queue_free()  # 安全销毁原节点
		
	var current_type = event_data["current_type"]
	var spawn_pos = event_data["position"]
	
	# 根据类型前缀自动匹配循环组
	var group_key = current_type.split("_")[0] + "_elements"  # 示例：danger_elements
	var cycle_order = CYCLE_GROUPS.get(group_key, [])
	
	if cycle_order.empty():
		printerr("未找到对应的循环组：", group_key)
		return
	
	var current_index = cycle_order.find(current_type)
	if current_index == -1:
		printerr("类型不在循环组内：", current_type)
		return
	
	# 计算下一个索引（循环）
	var next_index = (current_index + 1) % cycle_order.size()
	var next_type = cycle_order[next_index]
	
	# 通用生成逻辑
	var target_config = _select_lianpu_by_type(next_type)
	if target_config:
		_spawn_replacement(target_config, spawn_pos)

# 辅助方法：查找敌人配置
func _select_lianpu_by_type(type_name: String) -> Dictionary:
	# 通过脸谱类型筛选脸谱(type_name: String) -> Dictionary:
	for config in LIANPU_CONFIG:
		if config["type"] == type_name:
			return config
	printerr("未找到敌人配置：", type_name)
	return {}

# 辅助方法：生成替换敌人
func _spawn_replacement(lianpu_dic: Dictionary, pos: Vector2):
	var new_lianpu = lianpu_dic["scene"].instance()
	lianpu_container.add_child(new_lianpu)
	#new_lianpu.global_position = pos
	var mode = lianpu_dic["mode"]
	var reward_score=lianpu_dic["reward_score"]
	var speed=lianpu_dic["speed"]
	var lianpu_type=lianpu_dic["type"]
	var dic:={"mode":mode,
	"pos":pos,
	"reward_score":reward_score,
	"speed":speed,
	"lianpu_type":lianpu_type}
	
	if new_lianpu.has_method("init"):
		new_lianpu.init(dic)	
	 #添加渐入动画
#	new_enemy.modulate = Color.transparent
#	var tween=new_enemy.get_node("Tween")
#	tween.interpolate_property(new_enemy, "modulate", 
#	Color.transparent, Color.white, 0.3)
#	tween.start()

func _on_accelerate_spawn_begin(duration):
	DebugUtils.log("begin accelerate!:SpawnMgr")
	is_accelerate=true
	if is_decelerate:
		is_decelerate=false
	update_spawn_speed()	

func _on_accelerate_spawn_end(value):
	DebugUtils.log("end accelerate!:SpawnMgr")
	is_accelerate=false
	update_spawn_speed()	

func _on_decelerate_spawn_begin(duration):
	DebugUtils.log("begin decelerate!:SpawnMgr")
	is_decelerate=true
	if is_accelerate:
		is_accelerate=false
	update_spawn_speed()

func _on_decelerate_spawn_end(value):
	DebugUtils.log("end decelerate!:SpawnMgr")
	is_decelerate=false
	update_spawn_speed()	

func _on_wuxing_generation_available(lianpu_data):
	DebugUtils.log("_on_wuxing_generation_available:SpawnManager")
	# 初始化位置和模式和奖励分数
	var org_pos=lianpu_data["position"]
	var type=lianpu_data["lianpu_type"]
	var pos=get_random_circle_point(org_pos,100)
	# 通用生成逻辑
	var target_config = _select_lianpu_by_type(type)
	if target_config:
		_spawn_replacement(target_config, pos)


# 生成圆周随机坐标的工具函数
func get_random_circle_point(center: Vector2, radius: float) -> Vector2:
	# 1. 生成0~2π的随机角度（对应360°，randf()生成0~1的随机数）
	var random_angle = randf() * PI * 2.0
	
	# 2. 极坐标转直角坐标：计算偏移量
	var offset_x = radius * cos(random_angle)
	var offset_y = radius * sin(random_angle)
	var offset = Vector2(offset_x, offset_y)
	
	# 3. 圆心坐标 + 偏移量 = 圆周随机坐标
	return center + offset
