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
const ENEMY_CONFIG := [
	{
		"type": "normal",
		"scene": preload("res://scene/game_play/LianpuNormal.tscn"),
		"min_score": 0,
		"weight": 100,
		"reward_score":1,
		"speed":30
	},
	{
		"type": "danger_fire",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_fire.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 20,
		"reward_score":5,
		"speed":20
	},
	{
		"type": "danger_metal",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_metal.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 20,
		"reward_score":10,
		"speed":20
	},
	{
		"type": "danger_thorns",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_thorns.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 20,
		"reward_score":5,
		"speed":20
	},
	{
		"type": "danger_water",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_water.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 20,
		"reward_score":5,
		"speed":20
	},
	{
		"type": "prop_accelerate",
		"scene": preload("res://scene/game_play/LianpuProp/prop_accelerate.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 10,
		"reward_score":5,
		"speed":10
	},
	{
		"type": "prop_crazy",
		"scene": preload("res://scene/game_play/LianpuProp/prop_crazy.tscn"),
		"min_score": 100,#全局分数达到该分数才生成该lianpu
		"weight": 5,
		"reward_score":5,
		"speed":10
	},
	{
		"type": "prop_multiple",
		"scene": preload("res://scene/game_play/LianpuProp/prop_multiple.tscn"),
		"min_score": 80,#全局分数达到该分数才生成该lianpu
		"weight": 10,
		"reward_score":5,
		"speed":10
	},
	{
		"type": "prop_decelerate",
		"scene": preload("res://scene/game_play/LianpuProp/prop_decelerate.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 10,
		"reward_score":5,
		"speed":10
	}
	
]

onready var timer = $SpawnTimer
var current_score := 0
onready var enemy_container=$SpawnedEnemies

func _ready():
	update_spawn_speed()
	EventBus.connect("global_score_changed", self, "_on_score_changed")
	EventBus.connect("cycle_lianpu", self, "_on_cycle_lianpu")
	EventBus.connect("accelerate_spawn_begin", self, "_on_accelerate_spawn_begin")
	EventBus.connect("accelerate_spawn_end", self, "_on_accelerate_spawn_end")
	EventBus.connect("decelerate_spawn_begin", self, "_on_decelerate_spawn_begin")
	EventBus.connect("decelerate_spawn_end", self, "_on_decelerate_spawn_end")
	
func _on_score_changed(new_score: int):
	current_score = new_score
	update_spawn_speed()

func update_spawn_speed():

	DebugUtils.log("update_spawn_speed() - is_accelerate: " + str(is_accelerate) + ", is_decelerate: " + str(is_decelerate))
	# 原方法代码...
	# 根据分数加速生成：每1000分减少2%间隔时间
	var acceleration = pow(score_acceleration, floor(current_score / 1000.0))
	var current_spawn_interval
	if is_accelerate:
		current_spawn_interval=max(accelerate_spawn_interval, min_spawn_interval)
	elif is_decelerate:
		current_spawn_interval=max(decelerate_spawn_interval, min_spawn_interval)
	else:
		current_spawn_interval = max(base_spawn_interval * acceleration, min_spawn_interval)
	timer.wait_time = current_spawn_interval
	DebugUtils.log("当前生成间隔时间："+str(timer.wait_time))
	if timer.is_stopped():
		timer.start()

func _on_SpawnTimer_timeout():
	var enemy_data = _select_enemy()
	var enemy = enemy_data.scene.instance()
	enemy_container.add_child(enemy)
	
	# 初始化位置和模式和奖励分数
	var pos = _get_spawn_position()
	var mode = _get_random_taiji_mode()
	var reward_score=enemy_data.reward_score
	var speed=enemy_data.speed
	
	if enemy.has_method("init"):
		enemy.init(mode, pos,reward_score,speed)

func _select_enemy() -> Dictionary:
	# 筛选符合条件的敌人
	var available = []
	for config in ENEMY_CONFIG:
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


func _get_random_taiji_mode() -> int:
	# 配置权重字典
	var weights = {
		GameEnums.TaijiMode.huo: 25,
		GameEnums.TaijiMode.jin: 25,
		GameEnums.TaijiMode.mu: 25,
		GameEnums.TaijiMode.shui: 25
	}
	# 调用静态工具类
	return WeightedRandom.get_item(weights)

# SpawnManager.gd lianpu切换部分

# 配置不同敌人组的循环顺序（示例新增两组）
const CYCLE_GROUPS = {
	"danger_elements": ["danger_fire", "danger_metal", "danger_thorns", "danger_water"],
	"new_group1": ["typeA", "typeB", "typeC"],
	"new_group2": ["typeX", "typeY", "typeZ"]
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
	var target_config = _find_enemy_config(next_type)
	if target_config:
		_spawn_replacement(target_config, spawn_pos)

# 辅助方法：查找敌人配置
func _find_enemy_config(type_name: String) -> Dictionary:
	for config in ENEMY_CONFIG:
		if config["type"] == type_name:
			return config
	printerr("未找到敌人配置：", type_name)
	return {}

# 辅助方法：生成替换敌人
func _spawn_replacement(config: Dictionary, pos: Vector2):
	var new_enemy = config["scene"].instance()
	enemy_container.add_child(new_enemy)
	new_enemy.global_position = pos
	
	if new_enemy.has_method("init"):
		new_enemy.init(
			_get_random_taiji_mode(),
			pos,
			config["reward_score"],
			config["speed"]
		)
	 #添加渐入动画
	new_enemy.modulate = Color.transparent
	var tween=new_enemy.get_node("Tween")
	tween.interpolate_property(new_enemy, "modulate", 
	Color.transparent, Color.white, 0.3)
	tween.start()

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
