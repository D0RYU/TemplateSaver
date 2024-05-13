@tool
extends EditorPlugin

var dock_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/TemplateDock.tscn")
var dock: Control
var template_data: Object:
	get:
		return get_tree().root.get_node("TemplateData")

func _enter_tree() -> void:
	add_autoload_singleton.call_deferred("TemplateData", "res://addons/TemplateSaver/Code/Autoload/TemplateData.gd")
	add_autoload_singleton.call_deferred("Dialog", "res://addons/TemplateSaver/Code/Autoload/Dialog.gd")
	
	while !get_tree().root.has_node("TemplateData") or !get_tree().root.has_node("Dialog"):
		await get_tree().create_timer(0).timeout
	
	var user_path: String = OS.get_data_dir() + "/Godot/TemplateSaver/"
	var user_directory := DirAccess.open(OS.get_data_dir() + "/Godot/")
	
	if !user_directory.dir_exists("TemplateSaver"):
		user_directory.make_dir("TemplateSaver")
	
	user_directory = DirAccess.open(user_path)
	
	var read_file := FileAccess.open(user_path + "TemplatePath.dat", FileAccess.READ)
	var file_path: String = read_file.get_as_text().strip_edges()
	
	read_file.close()
	
	if !user_directory.file_exists("TemplatePath.dat") or !DirAccess.open(file_path):
		var write_file := FileAccess.open(user_path + "TemplatePath.dat", FileAccess.WRITE)
		
		template_data.data_path = user_path + "Templates/"
		write_file.store_string(user_path + "Templates/")
		write_file.close()
		
		if !user_directory.dir_exists("Templates"):
			user_directory.make_dir("Templates")
	else:
		var directory := DirAccess.open(file_path.rstrip("/").trim_suffix("Templates"))
		
		template_data.data_path = file_path
		read_file.close()
		
		if !directory.dir_exists("Templates"):
			directory.make_dir("Templates")
	
	dock = dock_scene.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, dock)
	AddCurrentTemplates(dock, template_data.data_path)

func AddCurrentTemplates(dock: Control, path: String) -> void:
	var directory: DirAccess = DirAccess.open(path)
	var add_button: TextureButton = dock.get_node("VBoxContainer/Top/Buttons/AddButton")
	
	if directory:
		directory.list_dir_begin()
		var file_name: String = directory.get_next()
		
		while file_name != "":
			if !directory.current_is_dir():
				add_button.FileSelected(path + file_name, false)
			
			file_name = directory.get_next()

func _exit_tree() -> void:
	remove_autoload_singleton("TemplateData")
	remove_autoload_singleton("Dialog")
	remove_control_from_docks(dock)
	
	if dock:
		dock.free()
