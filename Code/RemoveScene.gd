@tool
extends TextureButton

@onready var SceneLabel: Label = get_node("../Margin/Info/Label")

func OnPressed() -> void:
	var Confirmation: ConfirmationDialog = Dialog.NewConfirm('are you sure you want to remove "' + SceneLabel.text + '"?')
	Confirmation.confirmed.connect(Confirmed)

func Confirmed() -> void:
	if !TemplateData.Remove(SceneLabel.text):
		Dialog.NewAlert("template remove failed")
