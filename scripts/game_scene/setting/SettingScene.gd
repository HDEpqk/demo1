extends Node2D

onready var lianpu_bgm = $LianpuBGM
onready var lianpu_sfx = $LianpuSFX
onready var lianpu_return= $LianpuReturn
onready var center = $Center
onready var viewport_size = get_viewport().size


func _ready():
	lianpu_bgm.position.x = viewport_size.x / 2 - 100
	lianpu_bgm.position.y = viewport_size.y / 2
	
	lianpu_sfx.position.x = viewport_size.x / 2 + 100
	lianpu_sfx.position.y = viewport_size.y / 2
	
	center.position.x = viewport_size.x/2
	center.position.y = viewport_size.y/2+130
	
	lianpu_return.position.x = viewport_size.x / 2
	lianpu_return.position.y = viewport_size.y - 60
	
	var texture_size = $BG.get_size()
	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	$BG.rect_scale = Vector2(scale_x, scale_y)
	
