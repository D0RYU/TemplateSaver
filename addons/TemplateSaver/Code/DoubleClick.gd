@tool
extends MarginContainer

var FileManagerScene: PackedScene = preload("res://addons/TemplateSaver/Scenes/FileManager.tscn")

@onready var SceneLabel: Label = get_node("Info/Label")

var MouseOver: bool = false

func _input(Event: InputEvent) -> void:
	if MouseOver and Event is InputEventMouseButton:
		if Event.double_click and Event.button_index == MOUSE_BUTTON_LEFT:
			var FileManager: FileDialog = FileManagerScene.instantiate()
			FileManager.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			FileManager.file_selected.connect(FileSelected)
			
			EditorInterface.get_base_control().add_child.call_deferred(FileManager)

func FileSelected(Path: String) -> void:
	if get_tree().root.has_node("TemplateData") and get_tree().root.has_node("Dialog"):
		var TreeTemplateData: Object = get_tree().root.get_node("TemplateData")
		var TreeDialog: Object = get_tree().root.get_node("Dialog")
		
		if Path.get_extension() == "tscn":
			var Scene: PackedScene = TreeTemplateData.Data[SceneLabel.text].Scene
			
			ResourceSaver.save(Scene, Path)
		else:
			TreeDialog.NewAlert("invalid save, tscn expected")

func MouseEntered() -> void:
	MouseOver = true

func MouseExited() -> void:
	MouseOver = false
