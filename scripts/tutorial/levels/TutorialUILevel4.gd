extends CanvasLayer

onready var viewport_size = get_viewport().size



onready var pause_btn=$PauseButton
onready var pause_panel=$PausePanel


#连击
onready var combo_label=$ComboLabel


func _ready():
	pause_btn.connect("pressed", self, "_on_pauseBtn_pressed")

	#订阅连击事件
	EventBus.connect("combo",self,"_on_combo")
	combo_label.hide()

	
func _on_pauseBtn_pressed():
	#UiMgr.show_control("PausePanel")
	pause_panel.show()
	var tween = pause_btn.get_node("Tween")
	tween.interpolate_property(pause_btn, "rect_scale",
	Vector2(1.2, 1.2), Vector2(1, 1), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


func _on_combo(combo_count,combo_timeout,lianpu_taiji_mode):
	match lianpu_taiji_mode:
		GameEnums.TaijiMode.huo:
			combo_label.self_modulate=Color("#e40000")
		GameEnums.TaijiMode.jin:
			combo_label.self_modulate=Color("#e6da29")
		GameEnums.TaijiMode.mu:
			combo_label.self_modulate=Color("#28c641")
		GameEnums.TaijiMode.shui:
			combo_label.self_modulate=Color("#2d93dd")
		GameEnums.TaijiMode.tu:
			combo_label.self_modulate=Color("#b36d41")
	var modulate=combo_label.self_modulate
	match combo_count:
		1:
			combo_label.self_modulate=modulate.darkened(0.4)
		2:
			combo_label.self_modulate=modulate.darkened(0.2)
		_:
			combo_label.self_modulate=modulate

	combo_label.text="连击×%d" % combo_count
	combo_label.show()
	var tween = combo_label.get_node("Tween")
	tween.interpolate_property(combo_label, "rect_scale",
	Vector2(4, 4), Vector2(3, 3), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_callback(combo_label,combo_timeout,"hide")
	tween.start()
