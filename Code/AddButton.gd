@tool
extends TextureButton

var FileManagerScene: PackedScene = preload("res://addons/TemplateManager/Scenes/FileManager.tscn")
var SceneUI: PackedScene = preload("res://addons/TemplateManager/Scenes/SceneUI.tscn")

@onready var SceneContainer: VBoxContainer = get_node("../../VBoxContainer")

func OnPressed() -> void:
	var FileManager: FileDialog = FileManagerScene.instantiate()
	FileManager.file_selected.connect(FileSelected)
	
	EditorInterface.get_base_control().add_child.call_deferred(FileManager)

func FileSelected(Path: String, StoreVar: bool = true) -> void:
	if StoreVar and Path.get_extension() != "tscn":
		Dialog.NewAlert('wrong extension type, got: ".' + Path.get_extension() + '", expected: ".tscn"')
		
		return
	
	var NewUI: HBoxContainer = SceneUI.instantiate()
	var SceneInfo: HBoxContainer = NewUI.get_node("Margin/Info")
	var SceneLabel: Label = SceneInfo.get_node("Label")
	var SceneName: String = Path.get_file().left(-5)
	var ID: String = str(ResourceUID.create_id())
	var Added: bool
	
	if StoreVar:
		var Template: PackedScene = load(Path)
		Added = TemplateData.Add(SceneName, ID, Template, NewUI)
		
		if Added:
			var File: FileAccess = FileAccess.open("C:/Godot/" + SceneName + "_" + ID + ".dat", FileAccess.WRITE)
			
			File.store_var(Template, true)
			File.close()
	else:
		var File: FileAccess = FileAccess.open(Path, FileAccess.READ)
		var Template: PackedScene = File.get_var(true)
		var Split: PackedStringArray = SceneName.split("_")
		
		SceneName = Split[0]
		ID = Split[1]
		Added = TemplateData.Add(SceneName, ID, Template, NewUI)
		
		File.close()
	
	if Added:
		NewUI.name = SceneName
		SceneLabel.text = SceneName
		SceneInfo.tooltip_text = SceneName + "\nType: Scene\nID: " + ID
		SceneContainer.add_child.call_deferred(NewUI)
	else:
		Dialog.NewAlert("template add failed")
