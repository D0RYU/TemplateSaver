@tool
extends Node

func NewConfirm(Text):
	var Confirmation: ConfirmationDialog = ConfirmationDialog.new()
	Confirmation.dialog_text = Text
	Confirmation.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	Confirmation.visible = true
	
	EditorInterface.get_base_control().add_child.call_deferred(Confirmation)
	return Confirmation

func NewAlert(Text):
	var Alert: AcceptDialog = AcceptDialog.new()
	Alert.dialog_text = Text
	Alert.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	Alert.visible = true
	
	EditorInterface.get_base_control().add_child.call_deferred(Alert)
	return Alert
