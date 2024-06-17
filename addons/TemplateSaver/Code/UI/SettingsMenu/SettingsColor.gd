@tool
extends Control

@export var top: ColorRect
@export var bottom: ColorRect
@export var highlight: ColorRect
@export var shadow: ColorRect
@export var outline: ColorRect

@onready var editor_settings: EditorSettings = EditorInterface.get_editor_settings()

func _ready() -> void:
	editor_settings.settings_changed.connect(SetColor)
	SetColor()

func SetColor() -> void:
	top.color = EditorColor.base_color
	bottom.color = EditorColor.GetHint(EditorColor.base_color, 0.75)
	highlight.color = EditorColor.accent_color
	shadow.color = EditorColor.GetHint(EditorColor.base_color, 0.6)
	outline.color = EditorColor.GetHint(EditorColor.base_color, 0.5)
