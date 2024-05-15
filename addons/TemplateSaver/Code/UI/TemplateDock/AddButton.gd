@tool
extends TextureButton

@onready var scene_container: VBoxContainer = get_node("../../../../Bottom/TabContainer/Add-On/Container")

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
	file_manager.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	file_manager.files_selected.connect(FilesSelected)
	
	EditorInterface.get_base_control().add_child.call_deferred(file_manager)

func SearchAll(text: String, matching: String, type: Variant = 0) -> Array[String]:
	var searches: Array[String] = []
	var regex := RegEx.new()
	regex.compile(matching)
	
	for search: Object in regex.search_all(text):
		searches.append(search.get_string(type))
	
	return searches

func SearchScene(scene_name: String, start: String, path: String) -> Array:
	var tscn_file := FileAccess.open(path, FileAccess.READ)
	var scripts: Array = SearchAll(tscn_file.get_as_text(), "ext_resource type=\"Script\" path=\"(?<script>.*\\.gd)\" id=\"", "script")
	var template: Array = []
	
	template.append([scene_name, load(path)])
	tscn_file.close()
	
	for script in scripts:
		var script_file := FileAccess.open(script, FileAccess.READ)
		var scenes: Array = SearchAll(script_file.get_as_text(), "(preload|load)\\(\"(?<scene>.*\\.tscn)\"\\)", "scene")
		
		for scene in scenes:
			var dependency: PackedScene = load(scene)
			if !is_instance_valid(dependency): continue
			
			var dependency_id: String = str(ResourceUID.create_id())
			var dependency_name: String = scene.get_file().left(-5)
			var dependency_file := FileAccess.open(start + dependency_name + "_" + dependency_id + ".dat", FileAccess.WRITE)
			
			template.append([dependency_name, dependency])
			template.append_array(SearchScene(scene_name, start, scene))
			dependency_file.store_var(dependency, true)
			dependency_file.close()
	
	return template

func FilesSelected(paths: Array, store_var: bool = true) -> void:
	for path in paths:
		if store_var and path.get_extension() != "tscn":
			dialog.NewAlert('wrong extension type, got: ".' + path.get_extension() + '", expected: ".tscn"')
			
			return
		
		var new_ui: HBoxContainer = scene_ui.instantiate()
		var scene_info: HBoxContainer = new_ui.get_node("Margin/Info")
		var scene_label: Label = scene_info.get_node("Label")
		var scene_name: String = path.get_file().left(-5)
		var id: String = str(ResourceUID.create_id())
		var added: bool
		
		if store_var:
			var template: PackedScene = load(path)
			var scene_id_name = scene_name + "_" + id
			
			if !template_data.data.has(scene_name):
				DirAccess.make_dir_absolute(template_data.data_path + scene_id_name)
				
				var start: String = template_data.data_path + scene_id_name + "/"
				var file := FileAccess.open(start + scene_id_name + ".dat", FileAccess.WRITE)
				var dependencies: Array = SearchScene(scene_name, start, path)
				
				file.store_var(template, true)
				file.close()
				
				added = template_data.Add(scene_name, id, dependencies, new_ui)
		else:
			var directory := DirAccess.open(path)
			directory.list_dir_begin()
			scene_name = path.split("/", false)[-1]
			var file_name: String = directory.get_next()
			var template: Array = []
			
			while file_name != "":
				var file := FileAccess.open(path + "/" + file_name, FileAccess.READ)
				
				template.append([file_name.split("_")[0], file.get_var(true)])
				file_name = directory.get_next()
				file.close()
			
			var split: PackedStringArray = scene_name.split("_")
			
			scene_name = split[0]
			id = split[1]
			added = template_data.Add(scene_name, id, template, new_ui)
		
		if added:
			new_ui.name = scene_name
			scene_label.text = scene_name
			scene_info.tooltip_text = scene_name + "\nType: Scene\nID: " + id
			scene_container.add_child.call_deferred(new_ui)
		else:
			dialog.NewAlert("template add failed")
