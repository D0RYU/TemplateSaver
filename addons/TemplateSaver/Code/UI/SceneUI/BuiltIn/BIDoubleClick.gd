@tool
extends MarginContainer

@onready var scene_label: Label = get_node("Info/Label")
@onready var scene_path: String = "res://addons/TemplateSaver/Scenes/Templates/" + scene_label.text + ".dat"

var file_manager_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/FileManager.tscn")
var mouse_over: bool = false
var dialog: Object:
	get:
		return get_tree().root.get_node("Dialog")

func _ready() -> void:
	tooltip_text = scene_label.text + "\nType: Scene\nPath: res://TemplateSaver/Scenes/Templates/" + scene_label.text + ".dat"

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
			file_manager.title = "Save Scene to Project"
			
			EditorInterface.get_base_control().add_child.call_deferred(file_manager)

func FileSelected(path: String) -> void:
	var file := FileAccess.open(scene_path, FileAccess.READ)
	var template: PackedScene = file.get_var(true)
	
	file.close()
	
	if path.get_extension() == "tscn":
		ResourceSaver.save(template, path)
	else:
		dialog.NewAlert("invalid save, tscn expected")
