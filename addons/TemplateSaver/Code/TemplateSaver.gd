@tool
extends EditorPlugin

var dock_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/TemplateSaver.tscn")
var main_margin: MarginContainer
var template_data: Object:
	get:
		while !get_tree().root.has_node("TemplateData"):
			await get_tree().create_timer(0).timeout
		
		return get_tree().root.get_node("TemplateData")

func _enter_tree() -> void:
	add_autoload_singleton.call("TemplateData", "res://addons/TemplateSaver/Code/Autoload/TemplateData.gd")
	
	while !get_tree().root.has_node("TemplateData"):
		await get_tree().create_timer(0).timeout
	
	var user_path: String = OS.get_data_dir() + "/Godot/TemplateSaver/"
	var user_directory := DirAccess.open(OS.get_data_dir() + "/Godot/")
	
	if !user_directory.dir_exists("TemplateSaver"):
		user_directory.make_dir("TemplateSaver")
	
	user_directory = DirAccess.open(user_path)
	
	var read_file := FileAccess.open(user_path + "TemplatePath.dat", FileAccess.READ)
	var file_path: String = read_file.get_as_text().strip_edges() if read_file else user_path + "Templates/"
	
	read_file.close()
	
	if !user_directory.file_exists("TemplatePath.dat") or !DirAccess.open(file_path):
		var write_file := FileAccess.open(user_path + "TemplatePath.dat", FileAccess.WRITE)
		
		template_data.data_path = file_path
		write_file.store_string(file_path)
		write_file.close()
		
		if !user_directory.dir_exists("Templates"):
			user_directory.make_dir("Templates")
	else:
		var directory := DirAccess.open(file_path.rstrip("/").trim_suffix("Templates"))
		
		template_data.data_path = file_path
		
		if !directory.dir_exists("Templates"):
			directory.make_dir("Templates")
	
	if !user_directory.file_exists("PluginLocation.dat"):
		var write_file := FileAccess.open(user_path + "PluginLocation.dat", FileAccess.WRITE)
		
		template_data.plugin_location = 0
		write_file.store_string(str(0))
		write_file.close()
	else:
		read_file = FileAccess.open(user_path + "PluginLocation.dat", FileAccess.READ)
		template_data.plugin_location = int(read_file.get_as_text().strip_edges())
		read_file.close()
	
	if !user_directory.file_exists("ShowPrints.dat"):
		var write_file := FileAccess.open(user_path + "ShowPrints.dat", FileAccess.WRITE)
		
		template_data.show_prints = false
		write_file.store_string(str(false))
		write_file.close()
	else:
		read_file = FileAccess.open(user_path + "ShowPrints.dat", FileAccess.READ)
		template_data.show_prints = read_file.get_as_text().strip_edges() == "true"
		read_file.close()
	
	template_data.dock = dock_scene.instantiate()
	template_data.plugin = self
	
	match template_data.plugin_location:
		0:
			add_control_to_bottom_panel(template_data.dock, "Template Saver")
		1:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, template_data.dock)
	
	AddCurrentTemplates(template_data.dock, template_data.data_path)

func AddCurrentTemplates(dock: Control, path: String) -> void:
	var directory := DirAccess.open(path)
	var add_button: TextureButton = dock.get_node("VBoxContainer/Top/MarginContainer/Buttons/AddButton")
	
	if directory:
		directory.list_dir_begin()
		var file_name: String = directory.get_next()
		
		while file_name != "":
			if directory.current_is_dir():
				add_button.FilesSelected([path + file_name], false)
			
			file_name = directory.get_next()

func UpdateLocation(index: int) -> void:
	var user_path: String = OS.get_data_dir() + "/Godot/TemplateSaver/"
	var file := FileAccess.open(user_path + "PluginLocation.dat", FileAccess.WRITE)
	
	template_data.plugin_location = index
	file.store_string(str(index))
	file.close()

func LocationSelected(index: int) -> void:
	RemovePlugin()
	
	match index:
		0:
			add_control_to_bottom_panel(template_data.dock, "Template Saver")
			UpdateLocation(index)
		1:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, template_data.dock)
			UpdateLocation(index)

func RemovePlugin() -> void:
	match template_data.plugin_location:
		0:
			remove_control_from_bottom_panel(template_data.dock)
		1:
			remove_control_from_docks(template_data.dock)

func _exit_tree() -> void:
	remove_autoload_singleton("TemplateData")
	RemovePlugin()
	
	if is_instance_valid(template_data.dock):
		template_data.dock.free()
