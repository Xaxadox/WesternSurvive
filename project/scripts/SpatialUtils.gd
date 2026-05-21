class_name SpatialUtils
extends RefCounted

static func is_alive(node):
	return is_instance_valid(node) and bool(node.alive)

static func nearest_alive(source_position, candidates, fallback = null):
	var best = null
	var best_distance = INF

	for candidate in candidates:
		if not is_alive(candidate):
			continue

		var distance = source_position.distance_squared_to(candidate.global_position)
		if distance < best_distance:
			best_distance = distance
			best = candidate

	return best if best != null else fallback

static func nearest_valid(source_position, candidates, fallback = null):
	var best = null
	var best_distance = INF

	for candidate in candidates:
		if not is_instance_valid(candidate):
			continue

		var distance = source_position.distance_squared_to(candidate.global_position)
		if distance < best_distance:
			best_distance = distance
			best = candidate

	return best if best != null else fallback

static func has_alive_in_radius(source_position, candidates, radius):
	var radius_squared = radius * radius
	for candidate in candidates:
		if is_alive(candidate) and source_position.distance_squared_to(candidate.global_position) <= radius_squared:
			return true
	return false

static func has_valid_in_radius(source_position, candidates, radius):
	var radius_squared = radius * radius
	for candidate in candidates:
		if is_instance_valid(candidate) and source_position.distance_squared_to(candidate.global_position) <= radius_squared:
			return true
	return false

static func alive_in_radius(source_position, candidates, radius):
	var result = []
	var radius_squared = radius * radius
	for candidate in candidates:
		if is_alive(candidate) and source_position.distance_squared_to(candidate.global_position) <= radius_squared:
			result.append(candidate)
	return result

static func valid_in_radius(source_position, candidates, radius):
	var result = []
	var radius_squared = radius * radius
	for candidate in candidates:
		if is_instance_valid(candidate) and source_position.distance_squared_to(candidate.global_position) <= radius_squared:
			result.append(candidate)
	return result
