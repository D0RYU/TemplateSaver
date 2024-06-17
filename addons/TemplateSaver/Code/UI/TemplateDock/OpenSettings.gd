@tool
extends TextureButton

var settings_menu_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/SettingsMenu.tscn")
var settings_menu: Control

func OnPressed() -> void:
	if !settings_menu:
		settings_menu = settings_menu_scene.instantiate()
		EditorInterface.get_base_control().add_child.call_deferred(settings_menu)
	else:
		settings_menu.queue_free()
