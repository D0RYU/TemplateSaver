@tool
extends EditorPlugin

var DockScene: PackedScene = preload("res://addons/TemplateManager/Scenes/TemplateDock.tscn")
var Dock: Control

func _enter_tree() -> void:
	var Directory: DirAccess = DirAccess.open("C://")
	
	if !Directory.dir_exists("Godot"):
		Directory.make_dir("Godot")
	
	add_autoload_singleton.call_deferred("TemplateData", "res://addons/TemplateManager/Code/TemplateData.gd")
	add_autoload_singleton.call_deferred("Dialog", "res://addons/TemplateManager/Code/Dialog.gd")
	
	while !get_tree().root.has_node("TemplateData") and !get_tree().root.has_node("Dialog"):
		await get_tree().create_timer(0).timeout
	
	Dock = DockScene.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, Dock)
	AddCurrentTemplates(Dock, "C:/Godot/")

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
	remove_control_from_docks(Dock)
	
	if Dock:
		Dock.free()
