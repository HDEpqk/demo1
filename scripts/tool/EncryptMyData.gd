tool
extends EditorScript

var CRYPTO_KEY# 与解密时使用相同的密钥



func _run():  # EditorScript中使用_run()而非_ready()
	#save_encrypted_key()
	#CRYPTO_KEY=CryptoUtil.load_encrypted_key()
	# 待加密的敏感信息
	var app_id ="X-LC-Id: OMCWyoTJdgvCJxObvbCAISTF-gzGzoHsz"
	var app_key="X-LC-Key: la1EnPLVmpsW5QcWuONzIwj4"
	var master_key="X-LC-Key: yWwSlbbhoi4tFSEOYLXnd8lY,master"
	var rest_api ="https://omcwyotj.lc-cn-n1-shared.com"#临时的REST API 服务器地址
	
	
	# 调用CryptoUtil加密（需传入密钥参数）
	var encrypted_app_id = CryptoUtil.xor_encrypt(app_id, CRYPTO_KEY)
	var encrypted_app_key= CryptoUtil.xor_encrypt(app_key, CRYPTO_KEY)
	var encrypted_master_key= CryptoUtil.xor_encrypt(master_key, CRYPTO_KEY)
	var encrypted_rest_api = CryptoUtil.xor_encrypt(rest_api, CRYPTO_KEY)
	
	# 打印加密结果（用于复制到项目代码中）
	print("加密后的APP_ID（PoolByteArray）: PoolByteArray([%s])" % array_to_string(encrypted_app_id))
	print("加密后的APP_KEY（PoolByteArray）: PoolByteArray([%s])" % array_to_string(encrypted_app_key))
	print("加密后的MASTER_KEY（PoolByteArray）: PoolByteArray([%s])" % array_to_string(encrypted_master_key))
	print("加密后的服务器地址（PoolByteArray）: PoolByteArray([%s])" % array_to_string(encrypted_rest_api))
	
	# 验证解密是否正确
	var decrypted_app_id = CryptoUtil.xor_decrypt(encrypted_app_id, CRYPTO_KEY)
	var decrypted_app_key= CryptoUtil.xor_decrypt(encrypted_app_key, CRYPTO_KEY)
	var decrypted_master_key= CryptoUtil.xor_decrypt(encrypted_master_key, CRYPTO_KEY)
	var decrypted_rest_api = CryptoUtil.xor_decrypt(encrypted_rest_api, CRYPTO_KEY)
	print("解密验证APP_ID: %s" % [decrypted_app_id])
	print("解密验证APP_KEY: %s" % [decrypted_app_key])
	print("解密验证MASTER_KEY: %s" % [decrypted_master_key])
	print("解密验证REST_API: %s" % [decrypted_rest_api])
	
	#print("解密验证APP_ID: %s" % [app_id])
#	print("解密验证APP_KEY: %s" % [app_key])
#	print("解密验证MASTER_KEY: %s" % [master_key])
#	print("解密验证REST_API: %s" % [rest_api])
	

# 辅助函数：将PoolByteArray转为逗号分隔的字符串
func array_to_string(arr: PoolByteArray) -> String:
	var parts = []
	for byte in arr:
		parts.append(str(byte))
	return ",".join(parts)
	
func generate_key():
	var device_id = OS.get_unique_id()
	print("原始device_id:" + device_id)
	
	# 1. 移除特殊字符（避免干扰）
	var clean_id = device_id.replace("{", "").replace("}", "").replace("-", "")
	print("去除特殊字符后:" + clean_id)
	
	# 2. 确保长度至少8位（不足补0，超长截断）
	var safe_device_id = clean_id.pad_zeros(8)  # 补全
	if safe_device_id.length() > 8:
		safe_device_id = safe_device_id.substr(0, 8)  # 超长则截断前8位
	print("处理后safe_device_id:" + safe_device_id)
	
	# 3. 截取前8位和后8位（此时长度已固定为8位）
	var part1 = safe_device_id.substr(0, 8)
	var part2 = clean_id.right(8)  # 因长度固定，实际与part1相同，可换其他逻辑
	
	# 4. 拼接密钥（增加固定字符串增强复杂度）
	var raw_key = part1 + "_game_" + part2
	print("生成的raw_key:" + raw_key)
	return raw_key

# 开发阶段：加密密钥并保存为二进制资源
func save_encrypted_key():
	var raw_key = generate_key()
	print("raw_key:"+raw_key)
	var encrypted_key = CryptoUtil.xor_encrypt(raw_key, "temp_key")  # 临时加密
	print("加密后的raw_key（PoolByteArray）: PoolByteArray([%s])" % array_to_string(encrypted_key))
	var resource = Resource.new()
	resource.set_meta("encrypted_key", encrypted_key)
	ResourceSaver.save("res://scripts/tool/encrypted_key.tres", resource)

# 运行阶段：加载并解密密钥
func load_encrypted_key() -> String:
	var resource = load("res://scripts/tool/encrypted_key.tres")
	var encrypted_key = resource.get_meta("encrypted_key") as PoolByteArray
	var decrypted_key=CryptoUtil.xor_decrypt(encrypted_key,"temp_key")  # 解出原始密钥
	print("解密验证raw_key: %s" % [decrypted_key])
	return decrypted_key
