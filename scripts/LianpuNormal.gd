extends "res://scripts/Lianpu.gd"


onready var ui=Global.ui


func init(_mode:int, pos:Vector2):
	.init(_mode,pos)
	#初始能量值
	if Global.random!=null:
		energy=Global.random.randi_range(0, 10)
		print("初始能量："+str(energy))
	print("初始运算类型："+str(operation_type))
	update_energy_label()
	

func cycle_color():
	.cycle_color()
	update_energy_label()

func update_energy_label():
	match operation_type:
		GameEnums.OperationType.jia:
			$EnergyLabel.text="+"+str(energy)
			pass
		GameEnums.OperationType.jian:
			$EnergyLabel.text="-"+str(energy)
			pass
		GameEnums.OperationType.cheng:
			$EnergyLabel.text="×"+str(energy)
			pass
		GameEnums.OperationType.chu:
			$EnergyLabel.text="÷"+str(energy)
			pass
		_:
			pass

func queue_free():
#根据运算类型进行不同运算
	match operation_type:
		GameEnums.OperationType.jia:
			Global.energy+=energy
			pass
		GameEnums.OperationType.jian:
			Global.energy-=energy
			pass
		GameEnums.OperationType.cheng:
			Global.energy*=energy
			pass
		GameEnums.OperationType.chu:
			if energy==0:
				print("你÷了0所以game over!")
				#跳转到结束界面
				get_tree().change_scene("res://scene/GameOverScene.tscn")
			else:
				Global.energy/=energy
			pass
	if(ui==null):
		print("ui的实例为空")
	else:
		ui.update_energy(Global.energy)
		.queue_free()
