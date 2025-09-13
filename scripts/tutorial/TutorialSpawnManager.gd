# SpawnManager.gd
extends Node2D



# 敌人配置（类型、场景、最小分数、权重）
const LIANPU_CONFIG := [
	{
		"type": "normal_red",
		"scene": preload("res://scene/game_play/LianpuNormal/normal_red.tscn"),
		"min_score": 0,
		"weight": 10,
		"reward_score":1,
		"speed":20,
		"mode":GameEnums.TaijiMode.huo
	},
		{
		"type": "normal_yellow",
		"scene": preload("res://scene/game_play/LianpuNormal/normal_yellow.tscn"),
		"min_score": 0,
		"weight": 10,
		"reward_score":1,
		"speed":20,
		"mode":GameEnums.TaijiMode.jin		
	},
		{
		"type": "normal_green",
		"scene": preload("res://scene/game_play/LianpuNormal/normal_green.tscn"),
		"min_score": 0,
		"weight": 10,
		"reward_score":1,
		"speed":20,
		"mode":GameEnums.TaijiMode.mu		
	},
		{
		"type": "normal_blue",
		"scene": preload("res://scene/game_play/LianpuNormal/normal_blue.tscn"),
		"min_score": 0,
		"weight": 10,
		"reward_score":1,
		"speed":20,
		"mode":GameEnums.TaijiMode.shui
	},
	{
		"type": "danger_fire",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_fire.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 5,
		"reward_score":5,
		"speed":20,
		"mode":GameEnums.TaijiMode.huo
	},
	{
		"type": "danger_metal",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_metal.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 5,
		"reward_score":10,
		"speed":20,
		"mode":GameEnums.TaijiMode.jin
	},
	{
		"type": "danger_thorns",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_thorns.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 5,
		"reward_score":5,
		"speed":20,
		"mode":GameEnums.TaijiMode.mu
	},
	{
		"type": "danger_water",
		"scene": preload("res://scene/game_play/LianpuDanger/danger_water.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 5,
		"reward_score":5,
		"speed":20,
		"mode":GameEnums.TaijiMode.shui
	},
	{
		"type": "prop_accelerate",
		"scene": preload("res://scene/game_play/LianpuProp/prop_accelerate.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 3,
		"reward_score":10,
		"speed":30,
		"mode":GameEnums.TaijiMode.huo
	},
	{
		"type": "prop_crazy",
		"scene": preload("res://scene/game_play/LianpuProp/prop_crazy.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 1,
		"reward_score":30,
		"speed":40,
		"mode":GameEnums.TaijiMode.jin
	},
	{
		"type": "prop_multiple",
		"scene": preload("res://scene/game_play/LianpuProp/prop_multiple.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 3,
		"reward_score":10,
		"speed":30,
		"mode":GameEnums.TaijiMode.mu
	},
	{
		"type": "prop_decelerate",
		"scene": preload("res://scene/game_play/LianpuProp/prop_decelerate.tscn"),
		"min_score": 0,#全局分数达到该分数才生成该lianpu
		"weight": 3,
		"reward_score":5,
		"speed":30,
		"mode":GameEnums.TaijiMode.shui
	},
	{
		"type": "hide_red",
		"scene": preload("res://scene/game_play/LianpuHide/hide_red.tscn"),
		"min_score": 20,#全局分数达到该分数才生成该lianpu
		"weight": 2,
		"reward_score":10,
		"speed":20,
		"mode":GameEnums.TaijiMode.huo
	},
	{
		"type": "hide_yellow",
		"scene": preload("res://scene/game_play/LianpuHide/hide_yellow.tscn"),
		"min_score": 20,#全局分数达到该分数才生成该lianpu
		"weight": 2,
		"reward_score":10,
		"speed":20,
		"mode":GameEnums.TaijiMode.jin
	},
	{
		"type": "hide_green",
		"scene": preload("res://scene/game_play/LianpuHide/hide_green.tscn"),
		"min_score": 20,#全局分数达到该分数才生成该lianpu
		"weight": 2,
		"reward_score":10,
		"speed":20,
		"mode":GameEnums.TaijiMode.mu
	},
	{
		"type": "hide_blue",
		"scene": preload("res://scene/game_play/LianpuHide/hide_blue.tscn"),
		"min_score": 20,#全局分数达到该分数才生成该lianpu
		"weight": 2,
		"reward_score":10,
		"speed":20,
		"mode":GameEnums.TaijiMode.shui
	}
	
]


var current_score := 0
onready var lianpu_container=$SpawnedLianpus

func _ready():
	EventBus.connect("wuxing_generation_available",self,"_on_wuxing_generation_available")
	


# SpawnManager.gd lianpu切换部分
# 配置不同敌人组的循环顺序（示例新增两组）
const CYCLE_GROUPS = {
	"danger_elements": ["danger_fire", "danger_metal", "danger_thorns", "danger_water"],
	"normal_elements": ["normal_red", "normal_yellow", "normal_green","normal_blue"],
	"hide_elements":["hide_red","hide_yellow","hide_green","hide_blue"]
}



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
