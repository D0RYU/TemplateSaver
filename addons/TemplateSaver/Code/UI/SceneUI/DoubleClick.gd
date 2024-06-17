@tool
extends MarginContainer

@export var scene_label: Label
@export var rename: LineEdit
@export var panel: PanelContainer
@export var remove: TextureButton

@onready var panel_style: StyleBoxFlat = panel.get("theme_override_styles/panel")

var add_button: TextureButton
var mouse_over_rename: bool = false
var template_data: Object:
	get:
		while !get_tree().root.has_node("TemplateData"):
			await get_tree().create_timer(0).timeout
		
		return get_tree().root.get_node("TemplateData")

func _ready() -> void:
	while !template_data.dock: await get_tree().create_timer(0).timeout
	add_button = template_data.dock.get_node("VBoxContainer/Top/MarginContainer/Buttons/AddButton")

func MouseEnteredRename() -> void:
	mouse_over_rename = true

func MouseExitedRename() -> void:
	mouse_over_rename = false

func ResetCaret() -> void:
	rename.set_caret_column(rename.text.length())

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ENTER and rename.has_focus():
		ResetCaret.call_deferred()
		
		if event.pressed:
			if template_data.Rename(scene_label.text, rename.text):
				rename.release_focus()
				rename.visible = false
			else:
				Dialog.NewAlert("Invalid Name, \"" + rename.text + "\" already exists")
				rename.release_focus()
				rename.visible = false
