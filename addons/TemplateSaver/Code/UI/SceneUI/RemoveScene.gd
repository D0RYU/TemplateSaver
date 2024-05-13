@tool
extends TextureButton

@onready var scene_label: Label = get_node("../Margin/Info/Label")

var template_data: Object:
	get:
		return get_tree().root.get_node("TemplateData")
var dialog: Object:
	get:
		return get_tree().root.get_node("Dialog")

func OnPressed() -> void:
	var confirmation: ConfirmationDialog = dialog.NewConfirm("are you sure you want to remove \"%s\"?" % scene_label.text)
	
	confirmation.confirmed.connect(Confirmed)

func Confirmed() -> void:
	if !template_data.Remove(scene_label.text):
		dialog.NewAlert("template remove failed")
