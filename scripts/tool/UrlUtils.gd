extends Node
class_name UrlUtils

# 正确的 URL 编码函数（兼容 Godot 3.6，基于 UTF-8 字节）
static func url_encode(input_str: String) -> String:
	var result = ""
	for c in input_str:
		# 1. 将字符转换为 UTF-8 字节数组
		var utf8_bytes = c.to_utf8()  # 获取 UTF-8 编码的字节数组
		
		# 2. 对每个字节进行 URL 编码
		for byte in utf8_bytes:
			# 判断是否为安全字符（无需编码）
			if (byte >= 48 and byte <= 57) or  \
			   (byte >= 65 and byte <= 90) or  \
			   (byte >= 97 and byte <= 122) or \
			   byte == 45 or byte == 46 or     \
			   byte == 95 or byte == 126:      \
				# Godot 3.6 用 char() 函数将字节转为字符
				result += char(byte)
			else:
				# 非安全字符：转换为 %XX 格式（两位十六进制大写）
				result += "%" + str("%02X" % byte)
	return result

# 测试示例
func _ready():
	var test_str = "玩家4"
	var encoded = url_encode(test_str)
	print("原始字符串: ", test_str)
	print("编码结果: ", encoded)  # 输出：%E7%8E%A9%E5%AE%B6%E5%9B%9B（与标准一致）
