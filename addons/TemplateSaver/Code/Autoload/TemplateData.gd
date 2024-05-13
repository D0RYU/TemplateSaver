@tool
extends Node

var data_path = ""
var data: Dictionary = {}
var dialog: Object:
	get:
		return get_tree().root.get_node("Dialog")

func Robocopy(source: String, destination: String) -> bool:
	if MakeDirectory(destination):
		var output: Array = []
		var move_code: int = OS.execute("CMD.exe", ["/C", "robocopy", source, destination, "/move"], output)
		
		match move_code:
			0, 1, 2, 3, 4, 5, 6, 7:
				dialog.NewAlert("Move Successful:\n" + output[0].strip_edges())
				return true
			8:
				dialog.NewAlert("Error: Some files or directories could not be copied\n" + output[0].strip_edges())
			16:
				dialog.NewAlert("Error: could not copy any files\n" + output[0].strip_edges())
			_:
				dialog.NewAlert("Error: Invalid Command\n\"%s\"" % ("move " + source + " " + destination) + "\n" + output[0].strip_edges())
	
	return false

func RMDir(directory: String) -> bool:
	var output: Array = []
	var move_code: int = OS.execute("CMD.exe", ["/C", "rmdir", directory, "/s", "/q"], output)
	
	if move_code == 0:
		dialog.NewAlert("Remove Successful:\n" + output[0].strip_edges())
		return true
	else:
		dialog.NewAlert("Remove Failed:\n" + output[0].strip_edges())
	
	return false

func MakeDirectory(directory: String) -> bool:
	var directory_code: int = DirAccess.make_dir_absolute(directory)
	
	if directory_code != OK:
		dialog.NewAlert("Error: " + error_string(directory_code))
		return false
	
	return true

func MoveDirectory(source: String, destination: String) -> bool:
	source = source.rstrip("/")
	destination = destination.rstrip("/")
	
	var directory := DirAccess.open(destination)
	var source_name: String = source.split("/", false)[-1]
	var path1 = ProjectSettings.globalize_path(source).replace("/", "\\")
	var path2 = ProjectSettings.globalize_path(destination + "/" + source_name).replace("/", "\\")
	
	if !directory:
		dialog.NewAlert("Error: Invalid Source/Destination path")
	elif directory.dir_exists(source_name):
		var confirmation: ConfirmationDialog = dialog.NewConfirm("Are you sure you want to overwrite \"%s\"?" % (destination + "/" + source_name))
		var ready = [null]
		
		confirmation.confirmed.connect(func():
			if !RMDir(path2) or !Robocopy(path1, path2):
				ready[0] = false
			else:
				ready[0] = true
		)
		confirmation.canceled.connect(func():
			ready[0] = false
		)
		
		while ready[0] == null:
			await get_tree().create_timer(0).timeout
		
		return ready[0]
	else:
		return Robocopy(path1, path2)
	
	return false

func Move(to: String) -> bool:
	var user_path: String = OS.get_data_dir() + "/Godot/TemplateSaver/"
	var file := FileAccess.open(user_path + "TemplatePath.dat", FileAccess.WRITE)
	var moved: bool = await MoveDirectory(data_path, to)
	
	if moved:
		data_path = to + "/Templates/"
		file.store_string(to + "/Templates/")
	
	file.close()
	return moved

func IsDefaultPath() -> bool:
	var user_path: String = OS.get_data_dir() + "/Godot/TemplateSaver/Templates"
	
	return data_path.replace("//", "/").rstrip("/") == user_path.replace("//", "/").rstrip("/")

func Add(data_name: String, id: String, template: PackedScene, ui: HBoxContainer) -> bool:
	if data.has(data_name):
		return false
	
	print("add: ", data_name)
	data[data_name] = {
		id = id,
		scene = template.duplicate(),
		ui = ui
	}
	
	return true

func Remove(data_name: String) -> bool:
	if !data.has(data_name):
		return false
	
	var directory: DirAccess = DirAccess.open(data_path)
	
	directory.remove(data_name + "_" + data[data_name].id + ".dat")
	data[data_name].ui.queue_free()
	data.erase(data_name)
	print("remove: ", data)
	
	return true
