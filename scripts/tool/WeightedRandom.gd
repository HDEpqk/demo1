# WeightedRandom.gd
class_name WeightedRandom

static func get_item(weight_dict: Dictionary):
	if weight_dict.empty():
		push_error("权重字典为空！")
		return null
		
	var total = 0
	for key in weight_dict:
		total += weight_dict[key]
	DebugUtils.log("total:"+str(total))
	var rand = randi() % total
	DebugUtils.log("rand:"+str(rand))
	var current = 0
	for key in weight_dict:
		current += weight_dict[key]
		if rand < current:
			return key
	return weight_dict.keys()[0]
