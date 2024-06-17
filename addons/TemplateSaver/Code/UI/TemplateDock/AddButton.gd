@tool
extends TextureButton

@export var scene_container: VBoxContainer
@onready var separators: Array = [scene_container.get_node("SceneMiddle")]

var middle_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/SceneMiddle.tscn")
var file_manager_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/FileManager.tscn")
var scene_ui: PackedScene = preload("res://addons/TemplateSaver/Scenes/SceneUI.tscn")
var set_name_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/SetName.tscn")
var closest_separator: HSeparator
var is_dragging: bool = false
var moving_ui: Array
var template_data: Object:
	get:
		while !get_tree().root.has_node("TemplateData"):
			await get_tree().create_timer(0).timeout
		
		return get_tree().root.get_node("TemplateData")

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

func CleanSearch(template: Array) -> Array:
	var all_paths: Array = []
	var erase: Array = []
	
	for info in template:
		if all_paths.find(info[2]) == -1:
			all_paths.append(info[2])
		else:
			erase.append(info)
	
	for info in erase:
		DirAccess.remove_absolute(info[3])
		template.erase(info)
	
	return template

func SearchScene(scene_name: String, start: String, path: String, file_path: String, beginning: bool = true) -> Array:
	var tscn_file := FileAccess.open(path, FileAccess.READ)
	var scripts: Array = SearchAll(tscn_file.get_as_text(), "ext_resource type=\"Script\" path=\"(?<script>.*\\.gd)\" id=\"", "script")
	var template: Array = []
	
	if beginning:
		template.append([scene_name, load(path), path, file_path])
	
	tscn_file.close()
	
	for script in scripts:
		var script_file := FileAccess.open(script, FileAccess.READ)
		var scenes: Array = SearchAll(script_file.get_as_text(), "(preload|load)\\(\"(?<scene>.*\\.tscn)\"\\)", "scene")
		
		for scene in scenes:
			var dependency: PackedScene = load(scene)
			if !is_instance_valid(dependency): continue
			if path == scene: continue
			
			var dependency_id: String = str(ResourceUID.create_id())
			var dependency_name: String = scene.get_file().left(-5)
			var dependency_path: String = start + dependency_name + "@" + dependency_id + ".dat"
			var dependency_file := FileAccess.open(dependency_path, FileAccess.WRITE)
			
			template.append([dependency_name, dependency, scene, dependency_path])
			template.append_array(SearchScene(scene_name, start, scene, dependency_path, false))
			dependency_file.store_var(dependency, true)
			dependency_file.close()
	
	return template

func GetAlpha(color: Color, alpha: float = 1.0) -> Color:
	return Color(color.r, color.g, color.b, alpha)

func MoveItem(scene: MarginContainer, index: int) -> void:
	scene_container.move_child(scene, index)
	template_data.ReOrder.call_deferred()

func StartDrag(ui: Array) -> void:
	is_dragging = true
	moving_ui = ui

func StopDrag() -> void:
	is_dragging = false
	
	var ui_index: int = closest_separator.get_index() if closest_separator == separators[0] else closest_separator.get_node("../..").get_index()
	var separator_style: StyleBoxLine = closest_separator.get("theme_override_styles/separator")
	separator_style.color.a = 0
	
	if ui_index != moving_ui[0].get_index() and ui_index != moving_ui[0].get_index() - 1:
		var top_index: int = moving_ui[0].get_index()
		var closest_index: int = closest_separator.get_node("../..").get_index()
		var array_index: int = moving_ui.find(closest_separator.get_node("../.."))
		var got_self: bool = closest_separator.get_node("../..") in moving_ui
		
		for child in moving_ui:
			scene_container.remove_child(child)
		
		ui_index = closest_separator.get_index() if closest_separator == separators[0] else closest_separator.get_node("../..").get_index()
		
		if got_self:
			ui_index = closest_index - array_index - 1
		
		var is_below: bool = ui_index > top_index
		
		for child in moving_ui:
			scene_container.add_child(child)
			child.panel_style.border_color = GetAlpha(EditorColor.accent_color, 1)
			MoveItem(child, ui_index + 1)
			ui_index = child.get_index()

func _input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseMotion:
		var closest_position: float = INF
		var closest: HSeparator
		
		separators = separators.filter(func(separator) -> bool: return is_instance_valid(separator))
		
		for separator in separators:
			if separator.get_node("../..").visible:
				var min_value: float = min(closest_position, abs(get_viewport().get_mouse_position() - separator.global_position).y)
				separator.get("theme_override_styles/separator").color.a = 0
				
				if min_value != closest_position:
					closest_position = min_value
					closest = separator
		
		closest_separator = closest
		closest.get("theme_override_styles/separator").color.a = 1

func AddFile(new_ui: MarginContainer, scene_name: String, id: String, added: bool) -> void:
	if added:
		var container: VBoxContainer = new_ui.get_node("Container")
		var scene_info: HBoxContainer = container.get_node("Panel/Info")
		var scene_label: Label = scene_info.get_node("Label")
		var middle_scene: HSeparator = container.get_node("SceneMiddle")
		
		new_ui.name = scene_name
		scene_label.text = scene_name
		scene_info.tooltip_text = scene_name + "\nType: Scene\nID: " + id
		
		separators.append(middle_scene)
		scene_container.add_child.call_deferred(new_ui)
		template_data.ReOrder.call_deferred()
	else:
		Dialog.NewAlert("template add failed")

func FilesSelected(paths: Array, store_var: bool = true) -> void:
	var id: String = str(ResourceUID.create_id())
	
	if store_var:
		var set_name: Control = set_name_scene.instantiate()
		EditorInterface.get_base_control().add_child.call_deferred(set_name)
		
		set_name.title.text = "choose name for " + paths[0].get_file()
		set_name.name_entered.connect(func(new_name) -> void:
			if "." in new_name or ":" in new_name or "@" in new_name or "/" in new_name or '"' in new_name or "%" in new_name:
				Dialog.NewAlert("Invalid template name, the following character are not allowed:\n. : @ / \" %")
				return
			
			if template_data.data.has(new_name):
				Dialog.NewAlert("Invalid template name, \"" + new_name + "\" already exists")
			
			var new_ui: MarginContainer = scene_ui.instantiate()
			var new_ui_index: String = str(template_data.data.size())
			var new_id_name: String = new_ui_index + "@" + new_name + "@" + id
			var start: String = template_data.data_path + new_id_name + "/"
			var dependencies: Array = []
			
			if !template_data.data.has(new_name):
				DirAccess.make_dir_absolute(template_data.data_path + new_id_name)
				
				for path in paths:
					if path.get_extension() != "tscn":
						Dialog.NewAlert('wrong extension type, got: ".' + path.get_extension() + '", expected: ".tscn"')
						return
					
					var scene_name: String = path.get_file().left(-5)
					var template: PackedScene = load(path)
					var scene_id_name = scene_name + "@" + str(ResourceUID.create_id())
					var file_path: String = start + scene_id_name + ".dat"
					var file := FileAccess.open(file_path, FileAccess.WRITE)
					
					dependencies.append_array(SearchScene(new_name, start, path, file_path))
					file.store_var(template, true)
					file.close()
				
				dependencies = CleanSearch(dependencies)
				AddFile(new_ui, new_name, id, template_data.Add(new_name, new_ui_index, id, dependencies, new_ui))
		)
	else:
		for path in paths:
			var new_ui: MarginContainer = scene_ui.instantiate()
			var scene_name: String = path.get_file().left(-5)
			
			var directory := DirAccess.open(path)
			directory.list_dir_begin()
			scene_name = path.split("/", false)[-1]
			
			var file_name: String = directory.get_next()
			var template: Array = []
			
			while file_name != "":
				var file := FileAccess.open(path + "/" + file_name, FileAccess.READ)
				
				template.append([file_name.split("@")[0], file.get_var(true)])
				file_name = directory.get_next()
				file.close()
			
			var split: PackedStringArray = scene_name.split("@")
			var ui_index: String = split[0]
			
			scene_name = split[1]
			id = split[2]
			
			AddFile(new_ui, scene_name, id, template_data.Add(scene_name, ui_index, id, template, new_ui))
