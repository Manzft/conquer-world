extends Node

var astar = AStar2D.new()
var cities_by_id = {}

func add_city(city_node):
	var city_id = city_node.get_instance_id()
	if astar.has_point(city_id):
		return

	astar.add_point(city_id, city_node.position)
	cities_by_id[city_id] = city_node
	#print("NavigationManager: Registered city '", city_node.city_name, "' (ID: ", city_id, ")")

func add_connection(city_a, city_b):
	var id_a = city_a.get_instance_id()
	var id_b = city_b.get_instance_id()

	if not astar.has_point(id_a) or not astar.has_point(id_b):
		printerr("NavigationManager: Attempted to connect unregistered cities.")
		return

	astar.connect_points(id_a, id_b)
	#print("NavigationManager: Created connection between '", city_a.city_name, "' and '", city_b.city_name, "'")

func find_path(start_city, end_city):
	var start_id = start_city.get_instance_id()
	var end_id = end_city.get_instance_id()

	if not astar.has_point(start_id) or not astar.has_point(end_id):
		printerr("NavigationManager: Pathfinding failed. Start or end city not registered.")
		return []

	var path_positions = astar.get_point_path(start_id, end_id)
	return path_positions

func get_city_from_id(id):
	if cities_by_id.has(id):
		return cities_by_id[id]
	return null
