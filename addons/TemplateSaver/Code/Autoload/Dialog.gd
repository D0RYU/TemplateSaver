@tool
extends Node

func NewConfirm(text) -> ConfirmationDialog:
	var confirmation := ConfirmationDialog.new()
	confirmation.dialog_text = text
	confirmation.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	confirmation.visible = true
	confirmation.ready.connect(func():
		confirmation.size = Vector2(0, 0)
		confirmation.position -= confirmation.size / 2
	)
	
	EditorInterface.get_base_control().add_child.call_deferred(confirmation)
	return confirmation

func NewAlert(text) -> AcceptDialog:
	var alert := AcceptDialog.new()
	alert.dialog_text = text
	alert.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	alert.visible = true
	alert.ready.connect(func():
		alert.size = Vector2(0, 0)
		alert.position -= alert.size / 2
	)
	
	EditorInterface.get_base_control().add_child.call_deferred(alert)
	return alert
