# WeightedRandom.gd
class_name WeightedRandom

static func get_item(weight_dict: Dictionary):
	var total = 0
	for key in weight_dict:
		total += weight_dict[key]
	
	var rand = randi() % total
	var current = 0
	for key in weight_dict:
		current += weight_dict[key]
		if rand < current:
			return key
	return weight_dict.keys()[0]
