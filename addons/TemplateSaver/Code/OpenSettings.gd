@tool
extends TextureButton

var FileManagerScene: PackedScene = preload("res://addons/TemplateSaver/Scenes/SettingsMenu.tscn")
var SceneContainer: Control

func OnPressed() -> void:
	if !SceneContainer:
		SceneContainer = FileManagerScene.instantiate()
		EditorInterface.get_base_control().add_child.call_deferred(SceneContainer)
	else:
		SceneContainer.queue_free()
