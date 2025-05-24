# DataMgr.gd
extends Node

const CONFIG_PATH = "user://game_settings.cfg"
var _config = ConfigFile.new()

# 默认配置（首次运行时初始化）
var default_settings = {
	"audio": {
		"music_enabled": true,
		"sound_enabled": true,
	},
	"game": {
		"highest_score": 0
	}
}

# 单例初始化
func _ready():
	load_settings()

# 加载配置
func load_settings():
	var err = _config.load(CONFIG_PATH)
	if err == OK:  # 文件存在
		# 遍历所有section和key，用文件值覆盖默认值
		for section in default_settings:
			for key in default_settings[section]:
				var value = _config.get_value(section, key, default_settings[section][key])
				default_settings[section][key] = value
	else:  # 首次运行，创建默认配置
		save_settings()

# 保存配置
func save_settings():
	for section in default_settings:
		for key in default_settings[section]:
			_config.set_value(section, key, default_settings[section][key])
	_config.save(CONFIG_PATH)

# 对外接口：获取设置值
func get_setting(section, key):
	return default_settings.get(section, {}).get(key, null)

# 对外接口：修改设置值（自动保存）
func set_setting(section, key, value):
	if section in default_settings and key in default_settings[section]:
		default_settings[section][key] = value
		save_settings()
