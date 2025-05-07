# AnimationMgr.gd
extends Node

# 全局动画播放器
var _global_player: AnimationPlayer
# 注册的本地播放器字典 {key: AnimationPlayer}
var _local_players := {}  
# 动画资源池 {path: Animation}
var _animation_pool := {}
# 当前播放上下文 {player: AnimationPlayer, anim: String}
var _current_ctx := {}

signal animation_started(anim_name, player_key)
signal animation_finished(anim_name, player_key)

func _ready() -> void:
	# 初始化全局播放器
	_global_player = AnimationPlayer.new()
	add_child(_global_player)
	_global_player.connect("animation_finished", self, "_on_global_anim_finished")

# 注册本地播放器
func register_player(key: String, player: AnimationPlayer) -> void:
	_local_players[key] = player
	player.connect("animation_finished", self, "_on_local_anim_finished", [key])

# 播放动画（优先使用全局播放器）
func play(anim_name: String, 
		 speed: float = 1.0, 
		 loop: bool = false,
		 player_key: String = "",
		 callback: FuncRef = null) -> void:
		 
	var target_player: AnimationPlayer
	var using_global := false
	
	if player_key.empty() or not _local_players.has(player_key):
		target_player = _global_player
		using_global = true
	else:
		target_player = _local_players[player_key]
	
	if target_player.has_animation(anim_name):
		_current_ctx[target_player] = {
			"anim": anim_name,
			"callback": callback,
			"global": using_global
		}
		
		target_player.playback_speed = speed
		target_player.get_animation(anim_name).loop = loop
		target_player.play(anim_name)
		
		emit_signal("animation_started", anim_name, 
				   player_key if not using_global else "global")

# 动画完成回调处理
func _on_global_anim_finished(anim_name: String) -> void:
	_handle_finish(_global_player, anim_name)

func _on_local_anim_finished(anim_name: String, player_key: String) -> void:
	if _local_players.has(player_key):
		_handle_finish(_local_players[player_key], anim_name)

func _handle_finish(player: AnimationPlayer, anim_name: String) -> void:
	if _current_ctx.get(player, null):
		var ctx = _current_ctx[player]
		if ctx.callback and ctx.callback.is_valid():
			ctx.callback.call_func()
			
		emit_signal("animation_finished", anim_name, 
				   "global" if ctx.global else _get_player_key(player))
		
		_current_ctx.erase(player)

# 资源管理
func load_animation(path: String) -> void:
	if not _animation_pool.has(path):
		var anim = load(path)
		if anim is Animation:
			_animation_pool[path] = anim
			_global_player.add_animation(anim.resource_path.get_file(), anim)

func preload_animations(keys: Array) -> void:
	for key in keys:
		if not _animation_pool.has(key):
			var anim = load(key)
			_animation_pool[key] = anim

# 工具方法
func _get_player_key(player: AnimationPlayer) -> String:
	for key in _local_players:
		if _local_players[key] == player:
			return key
	return ""

# 跨场景动画混合（示例）
#func crossfade(new_anim: String, fade_time: float = 0.5, player_key: String = "") -> void:
#    var target_player = _global_player if player_key.empty() else _local_players.get(player_key)
#    if not target_player: return
#
#    if target_player.current_animation != "":
#        target_player.playback_speed = 1.0
#        target_player.queue("RESET")
#
#    target_player.play(new_anim)
#    target_player.seek(fade_time, true) [7](@ref)
