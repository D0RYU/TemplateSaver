@tool
extends TextureButton

@onready var SceneLabel: Label = get_node("../Margin/Info/Label")

func OnPressed() -> void:
	if get_tree().root.has_node("Dialog"):
		var TreeDialog: Object = get_tree().root.get_node("Dialog")
		
		var Confirmation: ConfirmationDialog = TreeDialog.NewConfirm('are you sure you want to remove "' + SceneLabel.text + '"?')
		Confirmation.confirmed.connect(Confirmed)

func Confirmed() -> void:
	if get_tree().root.has_node("TemplateData") and get_tree().root.has_node("Dialog"):
		var TreeTemplateData: Object = get_tree().root.get_node("TemplateData")
		var TreeDialog: Object = get_tree().root.get_node("Dialog")
		
		if !TreeTemplateData.Remove(SceneLabel.text):
			TreeDialog.NewAlert("template remove failed")
