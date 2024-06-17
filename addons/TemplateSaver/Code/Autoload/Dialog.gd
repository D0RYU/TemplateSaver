@tool
class_name Dialog extends Node

static func NewConfirm(text: String) -> ConfirmationDialog:
	var confirmation := ConfirmationDialog.new()
	confirmation.dialog_text = text
	confirmation.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	confirmation.ready.connect(func() -> void:
		confirmation.size = Vector2(0, 0)
		confirmation.position -= confirmation.size / 2
		confirmation.visible = true
	)
	
	EditorInterface.get_base_control().add_child.call_deferred(confirmation)
	return confirmation

static func NewAlert(text: String) -> AcceptDialog:
	var alert := AcceptDialog.new()
	alert.dialog_text = text
	alert.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	alert.ready.connect(func() -> void:
		alert.size = Vector2(0, 0)
		alert.position -= alert.size / 2
		alert.visible = true
	)
	
	EditorInterface.get_base_control().add_child.call_deferred(alert)
	return alert

static func NewContext(position: Vector2, data: Array) -> PopupMenu:
	var context := PopupMenu.new()
	
	context.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	context.popup_hide.connect(context.queue_free)
	context.ready.connect(func() -> void:
		for info: Dictionary in data:
			context.add_item(info.get("text", ""), -1, info.get("accel", 0))
			context.set_item_as_separator(-1, info.get("break", false))
		
		context.keep_title_visible = true
		context.size = Vector2(200, 0)
		context.position = Vector2(position.x, position.y + context.size.y)
		context.visible = true
	)
	context.index_pressed.connect(func(index: int) -> void:
		if data[index].has("call"):
			data[index].call.call()
	)
	
	EditorInterface.get_base_control().add_child.call_deferred(context)
	return context
