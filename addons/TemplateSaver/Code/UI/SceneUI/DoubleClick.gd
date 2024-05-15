@tool
extends MarginContainer

@onready var scene_label: Label = get_node("Info/Label")

var file_manager_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/FileManager.tscn")
var mouse_over: bool = false
var template_data: Object:
	get:
		return get_tree().root.get_node("TemplateData")
var dialog: Object:
	get:
		return get_tree().root.get_node("Dialog")

func MouseEntered() -> void:
	mouse_over = true

func MouseExited() -> void:
	mouse_over = false

func _input(event: InputEvent) -> void:
	if mouse_over and event is InputEventMouseButton:
		if event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
			var file_manager: FileDialog = file_manager_scene.instantiate()
			file_manager.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file_manager.file_selected.connect(FileSelected)
			
			EditorInterface.get_base_control().add_child.call_deferred(file_manager)

func FileSelected(path: String) -> void:
	if path.get_extension() == "tscn":
		if template_data.MakeDirectory(path.left(-5)):
			var template: Array = template_data.data[scene_label.text].scene
			
			for dependency in template:
				print(dependency[1], path.left(-5) + "/" + dependency[0] + ".tscn")
				ResourceSaver.save(dependency[1], path.left(-5) + "/" + dependency[0] + ".tscn")
	else:
		dialog.NewAlert("invalid save, tscn expected")
