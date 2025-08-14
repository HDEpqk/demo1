class_name CryptoUtil

# XOR 加密：将字符串与密钥异或处理
static func xor_encrypt(data: String, key: String) -> PoolByteArray:
	var data_bytes = data.to_utf8()  # 转为 UTF-8 字节数组
	var key_bytes = key.to_utf8()    # 密钥转为 UTF-8 字节数组
	var key_len = key_bytes.size()
	
	# 逐个字节异或
	for i in range(data_bytes.size()):
		data_bytes[i] ^= key_bytes[i % key_len]  # 用密钥字节循环异或
	
	return data_bytes  # 返回加密后的字节数组

# XOR 解密：与加密逻辑相同（异或两次恢复原始数据）
static func xor_decrypt(encrypted: PoolByteArray, key: String) -> String:
	var key_bytes = key.to_utf8()
	var key_len = key_bytes.size()
	# 构建新的 PoolByteArray 来复制数据
	var decrypted = PoolByteArray()
	for byte in encrypted:
		decrypted.append(byte)
	
	# 逐个字节异或解密
	for i in range(decrypted.size()):
		decrypted[i] ^= key_bytes[i % key_len]
	
	return decrypted.get_string_from_utf8()  # 转回字符串

