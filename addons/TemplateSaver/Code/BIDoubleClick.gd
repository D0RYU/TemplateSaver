@tool
extends MarginContainer

var FileManagerScene: PackedScene = preload("res://addons/TemplateSaver/Scenes/FileManager.tscn")

@onready var SceneLabel: Label = get_node("Info/Label")
@onready var ScenePath: String = "res://addons/TemplateSaver/Scenes/Templates/" + SceneLabel.text + ".dat"

var MouseOver: bool = false

func _ready() -> void:
	tooltip_text = SceneLabel.text + "\nType: Scene\nPath: res://TemplateSaver/Scenes/Templates/" + SceneLabel.text + ".dat"

func _input(Event: InputEvent) -> void:
	if MouseOver and Event is InputEventMouseButton:
		if Event.double_click and Event.button_index == MOUSE_BUTTON_LEFT:
			var FileManager: FileDialog = FileManagerScene.instantiate()
			FileManager.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			FileManager.file_selected.connect(FileSelected)
			FileManager.title = "Save Scene to Project"
			
			EditorInterface.get_base_control().add_child.call_deferred(FileManager)

func FileSelected(Path: String) -> void:
	if get_tree().root.has_node("Dialog"):
		var TreeDialog: Object = get_tree().root.get_node("Dialog")
		
		var File: FileAccess = FileAccess.open(ScenePath, FileAccess.READ)
		var Template: PackedScene = File.get_var(true)
		
		File.close()
		
		if Path.get_extension() == "tscn":
			ResourceSaver.save(Template, Path)
		else:
			TreeDialog.NewAlert("invalid save, tscn expected")

func MouseEntered() -> void:
	MouseOver = true

func MouseExited() -> void:
	MouseOver = false
