extends Control

# 显示面板
func show_panel():
	visible = true

# 隐藏面板
func hide_panel():
	visible = false

# 初始化面板
func init_panel():
	# 可以在这里添加初始化逻辑，例如加载数据、设置默认值等
	pass

# 销毁面板
func destroy_panel():
	queue_free()

# 更新面板数据
func update_panel_data(data):
	# 可以在这里添加更新数据的逻辑
	pass    
