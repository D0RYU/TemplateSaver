@tool
extends Control

@export var parent: Control
@export var moveables: Array[Control]

var mouse_over: bool = false
var left_click: bool = false
var old_mouse_position: Vector2
var old_control_position: Vector2

func _ready() -> void:
	for moveable in moveables:
		moveable.mouse_entered.connect(MouseEntered)
		moveable.mouse_exited.connect(MouseExited)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and (!event.pressed or mouse_over):
			left_click = event.pressed
			
			if left_click:
				old_mouse_position = event.position
				old_control_position = parent.global_position
	
	if left_click and event is InputEventMouseMotion:
		get_owner().move_to_front()
		parent.global_position = old_control_position + (event.position - old_mouse_position)

func MouseEntered() -> void:
	mouse_over = true

func MouseExited() -> void:
	mouse_over = false
