@tool
extends VBoxContainer

@onready var open_path: Button = $PathContainer/Path
@onready var reset_path: TextureButton = $PathContainer/Reset

var file_manager_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/FileManager.tscn")
var template_data: Object:
	get:
		return get_tree().root.get_node("TemplateData")

func _ready() -> void:
	reset_path.visible = !template_data.IsDefaultPath()
	
	if OS.get_name() != "Windows":
		open_path.disabled = true
		reset_path.visible = false
	
	open_path.text = template_data.data_path
	open_path.tooltip_text = "Open Data Path\nPath: " + template_data.data_path

func ChangeDataPath() -> void:
	var file_manager: FileDialog = file_manager_scene.instantiate()
	file_manager.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_manager.dir_selected.connect(DirectorySelected)
	file_manager.filters = []
	file_manager.title = "Choose a new Data Directory"
	file_manager.access = FileDialog.ACCESS_FILESYSTEM
	
	EditorInterface.get_base_control().add_child.call_deferred(file_manager)

func DirectorySelected(path: String) -> void:
	if path.rsplit("/", false)[-1] == template_data.data_path.rsplit("/", false)[-2]: return
	if await template_data.Move(path):
		open_path.text = path + "Templates/"
		open_path.tooltip_text = "Open Data Path\nPath: " + path + "Templates/"
		reset_path.visible = !template_data.IsDefaultPath()

func DataPathOpened() -> void:
	OS.shell_open(open_path.text)

func ResetDataPath() -> void:
	DirectorySelected(OS.get_data_dir() + "/Godot/TemplateSaver/")
