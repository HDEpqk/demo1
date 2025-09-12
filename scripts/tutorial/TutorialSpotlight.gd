extends CanvasLayer

# 遮罩层（黑色半透明）
onready var mask = $MaskTextureRect
# 聚光灯半径
export var spotlight_radius = 100.0
# 边缘柔化程度（0-1）
export var softness = 0.2

# 目标物体（需要高亮显示的物体）
var target_node = null

func _ready():
	# 初始化遮罩为全屏
	mask.rect_min_size = get_viewport().size
	update_spotlight()

func set_target(node: Node2D):
	"""设置聚光灯跟随的目标物体"""
	target_node = node
	update_spotlight()

func update_spotlight():
	"""更新聚光灯位置和形状"""
	if not target_node:
		return
	
	# 获取目标物体在屏幕上的位置（转换为UI坐标）
	var target_pos = get_viewport().size/2
	
	# 创建遮罩纹理（黑色背景+透明圆形）
	var texture = ImageTexture.new()
	var image = Image.new()
	
	# 设置图像大小为屏幕尺寸
	var size = get_viewport().size
	image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	# 填充黑色半透明背景
	image.fill(Color(0, 0, 0, 0.7))  # 最后一个参数是透明度（0.7表示70%不透明）
	
	# 绘制透明圆形（聚光区域）
	draw_soft_circle(image, target_pos, spotlight_radius, softness)
	
	# 应用纹理到遮罩
	texture.create_from_image(image)
	mask.texture = texture

func draw_soft_circle(image: Image, center: Vector2, radius: float, soft: float):
	"""绘制带柔化边缘的透明圆形"""
	var inner_radius = radius * (1 - soft)
	
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pos = Vector2(x, y)
			var distance = pos.distance_to(center)
			
			# 在圆形范围内设置透明度
			if distance < inner_radius:
				# 完全透明区域
				image.set_pixel(x, y, Color(0, 0, 0, 0))
			elif distance < radius:
				# 边缘过渡区域（从透明到半透明）
				var t = (distance - inner_radius) / (radius - inner_radius)
				var alpha = 0.7 * t  # 0.7是背景透明度
				image.set_pixel(x, y, Color(0, 0, 0, alpha))


