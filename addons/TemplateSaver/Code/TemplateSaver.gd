@tool
extends EditorPlugin

var DockScene: PackedScene = preload("res://addons/TemplateSaver/Scenes/TemplateDock.tscn")
var Dock: Control

func _enter_tree() -> void:
	var DriveIndex = DirAccess.open("res://").get_current_drive()
	var DriveName = DirAccess.get_drive_name(DriveIndex)
	var Directory: DirAccess = DirAccess.open(DriveName + "/")
	
	if !Directory.dir_exists("Godot"):
		Directory.make_dir("Godot")
	
	add_autoload_singleton.call_deferred("TemplateData", "res://addons/TemplateSaver/Code/TemplateData.gd")
	add_autoload_singleton.call_deferred("Dialog", "res://addons/TemplateSaver/Code/Dialog.gd")
	
	while !get_tree().root.has_node("TemplateData") or !get_tree().root.has_node("Dialog"):
		await get_tree().create_timer(0).timeout
	
	var TreeTemplateData: Object = get_tree().root.get_node("TemplateData")
	
	TreeTemplateData.DataPath = DriveName + "/Godot/"
	Dock = DockScene.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, Dock)
	AddCurrentTemplates(Dock, TreeTemplateData.DataPath)

func AddCurrentTemplates(Dock: Control, Path: String) -> void:
	var Directory: DirAccess = DirAccess.open(Path)
	var AddButton: TextureButton = Dock.get_node("Buttons/AddButton")
	
	if Directory:
		Directory.list_dir_begin()
		var FileName: String = Directory.get_next()
		
		while FileName != "":
			if !Directory.current_is_dir():
				AddButton.FileSelected(Path + FileName, false)
			
			FileName = Directory.get_next()

func _exit_tree() -> void:
	remove_autoload_singleton("TemplateData")
	remove_autoload_singleton("Dialog")
	remove_control_from_docks(Dock)
	
	if Dock:
		Dock.free()
