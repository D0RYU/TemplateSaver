@tool
extends VBoxContainer

@export var open_path: Button
@export var reset_path: TextureButton
@export var option_button: OptionButton
@export var check_button: CheckButton

var file_manager_scene: PackedScene = preload("res://addons/TemplateSaver/Scenes/FileManager.tscn")
var template_data: Object:
	get:
		while !get_tree().root.has_node("TemplateData"):
			await get_tree().create_timer(0).timeout
		
		return get_tree().root.get_node("TemplateData")

func _ready() -> void:
	option_button.selected = template_data.plugin_location
	check_button.button_pressed = template_data.show_prints
	option_button.item_selected.connect(template_data.plugin.LocationSelected)
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

func ShowPrint(enabled: bool) -> void:
	var user_path: String = OS.get_data_dir() + "/Godot/TemplateSaver/"
	var file := FileAccess.open(user_path + "ShowPrints.dat", FileAccess.WRITE)
	
	template_data.show_prints = enabled
	file.store_string(str(enabled))
	file.close()
