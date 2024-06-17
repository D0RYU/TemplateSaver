@tool
extends Node

var dock: BoxContainer
var plugin: EditorPlugin
var data_path: String = ""
var plugin_location: int = -1
var show_prints: bool = false
var data: Dictionary = {}

func Robocopy(source: String, destination: String) -> bool:
	if MakeDirectory(destination):
		var output: Array = []
		var move_code: int = OS.execute("CMD.exe", ["/C", "robocopy", source, destination, "/move"], output)
		
		match move_code:
			0, 1, 2, 3, 4, 5, 6, 7:
				Dialog.NewAlert("Move Successful:\n" + output[0].strip_edges())
				return true
			8:
				Dialog.NewAlert("Error: Some files or directories could not be copied\n" + output[0].strip_edges())
			16:
				Dialog.NewAlert("Error: could not copy any files\n" + output[0].strip_edges())
			_:
				Dialog.NewAlert("Error: Invalid Command\n\"%s\"" % ("move " + source + " " + destination) + "\n" + output[0].strip_edges())
	
	return false

func RMDir(directory: String) -> bool:
	var output: Array = []
	var move_code: int = OS.execute("CMD.exe", ["/C", "rmdir", directory, "/s", "/q"], output)
	
	if move_code == 0:
		Dialog.NewAlert("Remove Successful:\n" + output[0].strip_edges())
		return true
	else:
		Dialog.NewAlert("Remove Failed:\n" + output[0].strip_edges())
	
	return false

func RemoveTemplate(path: String) -> bool:
	var directory: DirAccess = DirAccess.open(path)
	var directories: Array = [path]
	
	if directory:
		directory.list_dir_begin()
		var file_name: String = directory.get_next()
		
		while file_name != "":
			if directory.current_is_dir():
				directories.append(path + "/" + file_name)
				RemoveTemplate(path + "/" + file_name)
			else:
				var directory_code: int = DirAccess.remove_absolute(path + "/" + file_name)
				
				if directory_code != OK:
					Dialog.NewAlert("Error Deleting File: " + error_string(directory_code) + "\nPath: " + path + "/" + file_name)
					return false
			
			file_name = directory.get_next()
		
		for directory_path in directories:
			var directory_code: int = DirAccess.remove_absolute(directory_path)
			
			if directory_code != OK:
				Dialog.NewAlert("Error Deleting Directory: " + error_string(directory_code) + "\nPath: " + directory_path)
				return false
	
	return true

func MakeDirectory(directory: String) -> bool:
	var directory_code: int = DirAccess.make_dir_absolute(directory)
	
	if directory_code != OK:
		Dialog.NewAlert("Error: " + error_string(directory_code))
		return false
	
	return true

func MoveDirectory(source: String, destination: String) -> bool:
	source = MakeValid(source)
	destination = MakeValid(destination)
	
	var directory := DirAccess.open(destination)
	var source_name: String = source.split("/", false)[-1]
	var path1 = ProjectSettings.globalize_path(source).replace("/", "\\")
	var path2 = ProjectSettings.globalize_path(destination + "/" + source_name).replace("/", "\\")
	
	if !directory:
		Dialog.NewAlert("Error: Invalid Source/Destination path")
	elif directory.dir_exists(source_name):
		var confirmation: ConfirmationDialog = Dialog.NewConfirm("Are you sure you want to overwrite \"%s\"?" % (destination + "/" + source_name))
		var ready = [null]
		
		confirmation.confirmed.connect(func() -> void:
			if !RMDir(path2) or !Robocopy(path1, path2):
				ready[0] = false
			else:
				ready[0] = true
		)
		confirmation.canceled.connect(func() -> void:
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

func MakeValid(path: String) -> String:
	return path.replace("//", "/").rstrip("/")

func IsDefaultPath() -> bool:
	var user_path: String = OS.get_data_dir() + "/Godot/TemplateSaver/Templates"
	
	return MakeValid(data_path) == MakeValid(user_path)

func GetOrder() -> Array:
	return dock.add_on_container.get_children().filter(func(child: Control) -> bool: return child is MarginContainer)

func ReOrder() -> bool:
	var order: Array = GetOrder()
	
	for index: int in order.size():
		var data_name: String = order[index].scene_label.text
		
		if !data.has(data_name):
			return false
		
		var old_path: String = data[data_name].index + "@" + data_name + "@" + data[data_name].id
		var new_path: String = str(index) + "@" + data_name + "@" + data[data_name].id
		
		DirAccess.open(data_path).rename(old_path, new_path)
		data[data_name].index = str(index)
	
	return true

func Rename(old_name: String, new_name: String) -> bool:
	new_name = new_name.strip_edges()
	
	if "." in new_name or ":" in new_name or "@" in new_name or "/" in new_name or '"' in new_name or "%" in new_name:
		Dialog.NewAlert("Invalid template name, the following character are not allowed:\n. : @ / \" %")
		return true
	
	if old_name == new_name:
		return true
	
	if data.has(new_name) or new_name == "":
		return false
	
	if show_prints:
		print("renamed: \"", old_name, "\" to \"", new_name, "\"")
	
	data[new_name] = data[old_name]
	data[new_name].ui.scene_label.text = new_name
	data.erase(old_name)
	
	var old_path: String = data[new_name].index + "@" + old_name + "@" + data[new_name].id
	var new_path: String = data[new_name].index + "@" + new_name + "@" + data[new_name].id
	
	DirAccess.open(data_path).rename(old_path, new_path)
	
	return true

func Add(data_name: String, index: String, id: String, template: Array, ui: MarginContainer) -> bool:
	if data.has(data_name):
		return false
	
	if show_prints:
		print("add: ", data_name)
	
	for count in template.size():
		template[count][1] = template[count][1].duplicate()
	
	data[data_name] = {
		index = index,
		id = id,
		scene = template,
		ui = ui
	}
	
	return true

func Remove(data_names: Array) -> bool:
	for data_name in data_names:
		if !data.has(data_name):
			return false
		
		var directory: DirAccess = DirAccess.open(data_path)
		var ui: MarginContainer = data[data_name].ui
		
		if show_prints:
			print("remove: ", data_name)
		
		if !RemoveTemplate(data_path.replace("/", "\\") + data[data_name].index + "@" + data_name + "@" + data[data_name].id):
			return false
		
		ui.queue_free()
		data.erase(data_name)
		
		while is_instance_valid(ui):
			await get_tree().create_timer(0).timeout
		
		ReOrder()
	
	Dialog.NewAlert("Remove Successful")
	return true
