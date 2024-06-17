@tool
extends TextureButton

@export var scene_label: Label

var template_data: Object:
	get:
		while !get_tree().root.has_node("TemplateData"):
			await get_tree().create_timer(0).timeout
		
		return get_tree().root.get_node("TemplateData")
		
func OnPressed() -> void:
	var confirmation: ConfirmationDialog = Dialog.NewConfirm("are you sure you want to remove \"%s\"?" % scene_label.text)
	
	confirmation.confirmed.connect(Confirmed)

func Confirmed() -> void:
	if !await template_data.Remove([scene_label.text]):
		Dialog.NewAlert("template remove failed")
