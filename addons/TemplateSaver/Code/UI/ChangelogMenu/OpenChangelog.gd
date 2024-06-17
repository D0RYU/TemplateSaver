@tool
extends TextureButton

var changelog_menu_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/ChangelogMenu.tscn")
var changelog_menu: Control

func OnPressed() -> void:
	if !changelog_menu:
		changelog_menu = changelog_menu_scene.instantiate()
		EditorInterface.get_base_control().add_child.call_deferred(changelog_menu)
	else:
		changelog_menu.queue_free()
