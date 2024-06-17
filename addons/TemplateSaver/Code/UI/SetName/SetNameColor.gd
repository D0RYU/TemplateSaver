@tool
extends Control

signal name_entered

@export var title: Label
@export var outline: ColorRect
@export var fill: ColorRect
@export var split: ColorRect
@export var name_edit: LineEdit
@export var enter: Button

@onready var editor_settings: EditorSettings = EditorInterface.get_editor_settings()

var is_hovered: bool = false

func _ready() -> void:
	editor_settings.settings_changed.connect(SetColor)
	SetColor()

func ResetCaret() -> void:
	name_edit.set_caret_column(name_edit.text.length())

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ENTER and name_edit.has_focus():
		ResetCaret.call_deferred()
		NameEntered()
	
	if !is_hovered and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		name_edit.release_focus()

func SetColor() -> void:
	fill.color = EditorColor.GetHint(EditorColor.base_color, 0.75)
	outline.color = EditorColor.base_color
	split.color = EditorColor.GetHint(EditorColor.base_color, 0.6)
	enter.get("theme_override_styles/normal").bg_color = EditorColor.GetHint(EditorColor.base_color, 0.6)
	enter.get("theme_override_styles/hover").bg_color = EditorColor.GetHint(EditorColor.base_color, 0.8)

func MouseEntered():
	is_hovered = true

func MouseExited():
	is_hovered = false

func NameEntered():
	name_entered.emit(name_edit.text)
	queue_free()
