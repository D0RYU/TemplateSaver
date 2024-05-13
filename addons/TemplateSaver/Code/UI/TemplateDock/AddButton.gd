@tool
extends TextureButton

@onready var scene_container: VBoxContainer = get_node("../../../Bottom/TabContainer/Add-On/Container")

var file_manager_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/FileManager.tscn")
var scene_ui: PackedScene = preload("res://addons/TemplateSaver/Scenes/SceneUI.tscn")
var template_data: Object:
	get:
		return get_tree().root.get_node("TemplateData")
var dialog: Object:
	get:
		return get_tree().root.get_node("Dialog")

func OnPressed() -> void:
	var file_manager: FileDialog = file_manager_scene.instantiate()
	file_manager.file_selected.connect(FileSelected)
	
	EditorInterface.get_base_control().add_child.call_deferred(file_manager)

func FileSelected(path: String, store_var: bool = true) -> void:
	if store_var and path.get_extension() != "tscn":
		dialog.NewAlert('wrong extension type, got: ".' + path.get_extension() + '", expected: ".tscn"')
		
		return
	
	var new_ui: HBoxContainer = scene_ui.instantiate()
	var scene_info: HBoxContainer = new_ui.get_node("Margin/Info")
	var scene_label: Label = scene_info.get_node("Label")
	var scene_name: String = path.get_file().left(-4 if path.get_extension() == "dat" else -5)
	var id: String = str(ResourceUID.create_id())
	var added: bool
	
	print(path.get_file(), scene_name)
	
	if store_var:
		var template: PackedScene = load(path)
		added = template_data.Add(scene_name, id, template, new_ui)
		
		if added:
			var file := FileAccess.open(template_data.data_path + scene_name + "_" + id + ".dat", FileAccess.WRITE)
			
			file.store_var(template, true)
			file.close()
	else:
		var file := FileAccess.open(path, FileAccess.READ)
		var template: PackedScene = file.get_var(true)
		var split: PackedStringArray = scene_name.split("_")
		
		scene_name = split[0]
		id = split[1]
		added = template_data.Add(scene_name, id, template, new_ui)
		
		file.close()
	
	if added:
		new_ui.name = scene_name
		scene_label.text = scene_name
		scene_info.tooltip_text = scene_name + "\nType: Scene\nID: " + id
		scene_container.add_child.call_deferred(new_ui)
	else:
		dialog.NewAlert("template add failed")
