@tool
extends TextureButton

var file_manager_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/SettingsMenu.tscn")
var scene_container: Control

func OnPressed() -> void:
	if !scene_container:
		scene_container = file_manager_scene.instantiate()
		EditorInterface.get_base_control().add_child.call_deferred(scene_container)
	else:
		scene_container.queue_free()
