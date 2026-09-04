extends Node2D

@export var camera_speed: float = 1880.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.125
@export var max_zoom: float = 2.0

@onready var camera: Camera2D = $Camera2D
@onready var cities_container: Node2D = $Cities
@onready var roads_container: Node2D = $Roads
@onready var ruta_visual: Line2D = $RutaVisual

const CityScene = preload("res://scenes/entities/City.tscn")
const RoadScene = preload("res://scenes/entities/Road.tscn")

var city_origin = null
var city_destination = null
var map_loaded: bool = false
var timer: float = 0.0
var dragging: bool = false
var last_mouse_pos: Vector2

func _ready() -> void:
	_create_map_tiles()
	_setup_cities()

func _process(delta: float) -> void:
	_handle_camera_movement(delta)
	if (!map_loaded):
		timer += delta

func _input(event: InputEvent) -> void:
	_handle_drag_input(event)
	_handle_zoom_input(event)

func _handle_camera_movement(delta: float) -> void:
	var direction = Vector2.ZERO
	if (Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A)): direction.x -= 1
	if (Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D)): direction.x += 1
	if (Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S)): direction.y += 1
	if (Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W)): direction.y -= 1
	
	camera.position += direction.normalized() * camera_speed / camera.zoom.x * delta

func _handle_drag_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.is_pressed()
			last_mouse_pos = event.position
	elif event is InputEventMouseMotion and dragging:
		camera.position -= (event.position - last_mouse_pos) / camera.zoom
		last_mouse_pos = event.position

func _handle_zoom_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var zoom_change = Vector2.ZERO
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_change = Vector2(zoom_speed, zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_change = Vector2(-zoom_speed, -zoom_speed)
		
		if zoom_change != Vector2.ZERO:
			camera.zoom = (camera.zoom + zoom_change).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func _setup_cities():
	for city_node in cities_container.get_children():
		city_node.city_name = city_node.name
		city_node.get_node("Label").text = city_node.city_name
		city_node.city_clicked.connect(_on_city_clicked)
		NavigationManager.add_city(city_node)

	for city_node in cities_container.get_children():
		var connections: Array = [
			city_node.connection_1,
			city_node.connection_2,
			city_node.connection_3,
			city_node.connection_4
		]
		for connection_path in connections:
			var connection_node = city_node.get_node(connection_path)
			var connection_name = ""
			if (is_instance_valid(connection_node)):
				connection_name = connection_node.name
			if (connection_name != ""):
				NavigationManager.add_connection(city_node, connection_node)
				_draw_permanent_road(city_node.position, connection_node.position)

func _draw_permanent_road(start: Vector2, end: Vector2):
	var road = RoadScene.instantiate()
	roads_container.add_child(road)
	road.points = PackedVector2Array([start, end])

func _on_city_clicked(city_node):
	if city_origin == null:
		city_origin = city_node
		ruta_visual.clear_points()
	elif city_origin == city_node:
		city_origin = null
		ruta_visual.clear_points()
	else:
		city_destination = city_node
		_draw_path()
		city_origin = null
		city_destination = null

func _draw_path():
	if city_origin and city_destination:
		var path_points = NavigationManager.find_path(city_origin, city_destination)
		if path_points and not path_points.is_empty():
			ruta_visual.points = path_points
		else:
			ruta_visual.clear_points()

func _create_map_tiles() -> void:
	for x in range(36):
		for y in range(24):
			var xstr: String = str(x); if (xstr.length() < 2): xstr = "0"+xstr
			var ystr: String = str(y); if (ystr.length() < 2): ystr = "0"+ystr
			var sprite = Sprite2D.new()
			$MapTiles.add_child(sprite)
			sprite.texture = load("res://resources/textures/map/tiles/tx_"+ystr+"_"+xstr+".jpg")
			if !(sprite.texture is Resource):
				sprite.texture = load("res://resources/textures/map/tiles/tx_00_00.jpg")
			sprite.centered = false
			sprite.position += Vector2(x*1200, y*900)
	map_loaded = true
