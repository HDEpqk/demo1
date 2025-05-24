extends Node2D


onready var music_list = [
   "res://audio/music/Three Red Hearts - Go (No Vocal).ogg",  # 歌曲1路径
	"res://audio/music/Three Red Hearts - Go.ogg",  # 歌曲2路径
	 "res://audio/music/Three Red Hearts - Modern Bits.ogg"  # 歌曲3路径
]
var current_index = 0       # 当前播放索引

onready var music_player =$AudioStreamPlayer
var is_bgm_on

func _ready():
	#从配置文件读取音乐是否被禁用
	is_bgm_on=DataMgr.get_setting("audio","music_enabled")
	play_next_song()
	

func play_next_song():
	if !is_bgm_on:return
	if music_list==null:
		return
	
	# 随机选择下一首歌曲（不重复随机需额外逻辑，此处为简单随机）
	current_index = rand_range(0, music_list.size() - 1)
	music_player.stream = load(music_list[current_index])
	music_player.play()


func _on_AudioStreamPlayer_finished():
	play_next_song()
