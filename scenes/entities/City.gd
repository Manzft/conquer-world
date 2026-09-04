extends Area2D

signal city_clicked(city_node)

var city_name: String = "New City"

@export var connection_1: NodePath = ""
@export var connection_2: NodePath = ""
@export var connection_3: NodePath = ""
@export var connection_4: NodePath = ""

@onready var label: Label = $Label
@onready var initial_scale: Vector2 = label.scale

func _ready():
	self.input_event.connect(_on_input_event)
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	label.pivot_offset = label.size / 2

func _process(_delta):
	if get_viewport().get_camera_2d():
		label.scale = initial_scale / get_viewport().get_camera_2d().zoom

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		emit_signal("city_clicked", self)

func _on_mouse_entered() -> void:
	$Label.show()

func _on_mouse_exited() -> void:
	$Label.hide()
