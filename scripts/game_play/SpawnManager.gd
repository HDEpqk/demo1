# SpawnManager.gd
extends Node2D

# 配置参数
export var base_spawn_interval := 3.0
export var score_acceleration := 0.98  # 每100分时间缩短系数

# 敌人配置（类型、场景、最小分数、权重）
const ENEMY_CONFIG := [
	{
		"type": "basic",
		#"scene": preload(""),
		"min_score": 0,
		"weight": 60
	},
	{
		"type": "shooter",
		#"scene": preload(""),
		"min_score": 200,
		"weight": 30
	},
	{
		"type": "elite",
		#"scene": preload(""),
		"min_score": 500,
		"weight": 10
	}
]

onready var timer = $SpawnTimer
var current_score := 0

func _ready():
	update_spawn_speed()
	GameEvents.connect("score_updated", self, "_on_score_updated")

func _on_score_updated(new_score: int):
	current_score = new_score
	update_spawn_speed()

func update_spawn_speed():
	# 根据分数加速生成：每100分减少2%间隔时间
	var acceleration = pow(score_acceleration, floor(current_score / 100.0))
	timer.wait_time = base_spawn_interval * acceleration
	if timer.is_stopped():
		timer.start()

func _on_SpawnTimer_timeout():
	var enemy_data = _select_enemy()
	var enemy = enemy_data.scene.instance()
	enemy_container.add_child(enemy)
	
	# 初始化位置和模式
	var pos = _get_spawn_position()
	var mode = _get_random_taiji_mode()
	
	if enemy.has_method("init"):
		enemy.init(mode, pos)

func _select_enemy() -> Dictionary:
	# 筛选符合条件的敌人（改用for循环替代filter）
	var available = []
	for config in ENEMY_CONFIG:
		if config.min_score <= current_score:
			available.append(config)
	
	# 计算权重总和（改用for循环替代reduce）
	var total_weight = 0
	for config in available:
		total_weight += config.weight
	
	# 加权随机选择
	var roll = randi() % total_weight
	for config in available:
		if roll < config.weight:
			return config
		roll -= config.weight
	return available[0]  # 保底返回第一个可用配置
