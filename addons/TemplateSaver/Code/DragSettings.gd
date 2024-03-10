@tool
extends ColorRect

var MouseOver: bool = false
var LeftClick: bool = false
var OldMousePosition: Vector2
var OldControlPositon: Vector2

func _input(Event: InputEvent) -> void:
	if Event is InputEventMouseButton:
		if Event.button_index == MOUSE_BUTTON_LEFT:
			if !Event.pressed or MouseOver:
				LeftClick = Event.pressed
				
				if LeftClick:
					OldMousePosition = Event.position
					OldControlPositon = get_parent().global_position
	
	if LeftClick and Event is InputEventMouseMotion:
		get_parent().global_position = OldControlPositon + (Event.position - OldMousePosition)

func MouseEntered() -> void:
	MouseOver = true

func MouseExited() -> void:
	MouseOver = false
