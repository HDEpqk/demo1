extends Node
var UIBasePanel = load("res://scripts/UIBasePanel.gd")
# 存储所有控件的字典
var controls = {}

# 动态加载并显示指定面板
func show_panel_dynamically(panel_name: String, panel_path: String):
	if panel_name in controls:
		show_control(panel_name)
	else:
		var panel_scene = load(panel_path)
		if panel_scene:
			var panel = panel_scene.instance()
			register_control(panel_name, panel)
			add_child(panel)
			show_control(panel_name)
		else:
			print("Failed to load panel from path: ", panel_path)

# 关闭并销毁指定面板
func close_and_destroy_panel(panel_name: String):
	if panel_name in controls:
		destroy_control(panel_name)

# 注册控件
func register_control(control_name: String, control: Control):
	controls[control_name] = control
	if control is UIBasePanel:
		control.init_panel()

# 显示指定控件
func show_control(control_name: String):
	if control_name in controls:
		if controls[control_name] is UIBasePanel:
			controls[control_name].show_panel()
		else:
			controls[control_name].visible = true

# 隐藏指定控件
func hide_control(control_name: String):
	if control_name in controls:
		if controls[control_name] is UIBasePanel:
			controls[control_name].hide_panel()
		else:
			controls[control_name].visible = false

# 销毁指定控件
func destroy_control(control_name: String):
	if control_name in controls:
		if controls[control_name] is UIBasePanel:
			controls[control_name].destroy_panel()
		else:
			controls[control_name].queue_free()
		controls.erase(control_name)

# 更新指定控件的数据
func update_control_data(control_name: String, data):
	if control_name in controls:
		if controls[control_name] is UIBasePanel:
			controls[control_name].update_panel_data(data)    
