extends Node2D
# 使用Timer节点定时生成
func _on_SpawnTimer_timeout():
	var color = get_random_color()
	print("生成颜色：", color.to_html())
	var pos =get_spawn_position()
	print("生成位置：", str(pos))
	var enemy = preload("res://scene/LianpuNormal.tscn").instance()
	print("是否在enemies组:", enemy.is_in_group("enemies")) # 应输出true
	add_child(enemy)
	enemy.init(color, pos)

func get_spawn_position():
	# 获取视口（屏幕）的尺寸
	var viewport_size = get_viewport().size
	var screen_edges = [
#		Vector2(rand_range(0, 960), 0),      # 上
		Vector2(rand_range(0, viewport_size.x), viewport_size.y),    # 下
		Vector2(0, rand_range(0, viewport_size.y)),      # 左
		Vector2(viewport_size.x, rand_range(0, viewport_size.y))     # 右
	]
	return screen_edges[randi() % screen_edges.size()] #

func get_random_color():
	var colors = [Color.red, Color.green, Color.blue]
	return colors[randi() % colors.size()] 
