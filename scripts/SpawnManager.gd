extends Node2D

# 配置参数
export var spawn_interval := 2.0  # 生成间隔（秒）
export var spawn_margin := 50.0   # 屏幕外生成边距
export var active_spawn_edges := [true, true, true, true]  # [上,下,左,右]是否激活生成边

const TAIJI_MODES = [
	GameEnums.TaijiMode.huo,
	GameEnums.TaijiMode.mu,
	GameEnums.TaijiMode.shui,
	GameEnums.TaijiMode.jin
]

onready var spawn_timer = $SpawnTimer
onready var enemy_container = $SpawnedEnemies  # 创建专门容器节点管理敌人

func _ready():
	# 初始化计时器
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()
	randomize()  # 确保每次运行随机不同

func _on_SpawnTimer_timeout():
	var mode = _get_random_taiji_mode()
	var pos = _get_spawn_position()
	
	var enemy = preload("res://scene/LianpuNormal.tscn").instance()
	enemy_container.add_child(enemy)  # 统一管理实例
	
	# 初始化前加入组（确保后续逻辑正确）
	enemy.add_to_group("enemies") 
	
	if enemy.has_method("init"):
		enemy.init(mode, pos)
		DebugUtils.log("生成敌人：模式=%s 位置=%s" % [GameEnums.TaijiMode.keys()[mode], pos])
	else:
		printerr("敌人实例缺少init方法！")
		enemy.queue_free()

func _get_spawn_position() -> Vector2:
	var viewport = get_viewport()
	var rect = viewport.get_visible_rect()
	rect = rect.grow(-spawn_margin)
	
	var edges = []
	if active_spawn_edges[0]: edges.append(Vector2(rand_range(rect.position.x, rect.end.x), rect.position.y - spawn_margin)) # 上
	if active_spawn_edges[1]: edges.append(Vector2(rand_range(rect.position.x, rect.end.x), rect.end.y + spawn_margin))       # 下
	if active_spawn_edges[2]: edges.append(Vector2(rect.position.x - spawn_margin, rand_range(rect.position.y, rect.end.y)))  # 左
	if active_spawn_edges[3]: edges.append(Vector2(rect.end.x + spawn_margin, rand_range(rect.position.y, rect.end.y)))       # 右
	
	# 安全判断空数组 
	return edges[randi() % edges.size()] if not edges.empty() else Vector2.ZERO

func _get_random_taiji_mode() -> int:
	# 加权随机示例：火30%，木25%，水25%，金20%
	var weights = {
		GameEnums.TaijiMode.huo: 30,
		GameEnums.TaijiMode.mu: 25,
		GameEnums.TaijiMode.shui: 25,
		GameEnums.TaijiMode.jin: 20
	}
	return WeightedRandom.get_item(weights)
