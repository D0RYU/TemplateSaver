@tool
extends ColorRect

var mouse_over: bool = false
var left_click: bool = false
var old_mouse_position: Vector2
var old_control_position: Vector2

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and (!event.pressed or mouse_over):
			left_click = event.pressed
			
			if left_click:
				old_mouse_position = event.position
				old_control_position = get_parent().global_position
	
	if left_click and event is InputEventMouseMotion:
		get_parent().global_position = old_control_position + (event.position - old_mouse_position)

func MouseEntered() -> void:
	mouse_over = true

func MouseExited() -> void:
	mouse_over = false
