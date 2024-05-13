@tool
extends Control

@export var top: ColorRect
@export var bottom: ColorRect
@export var highlight: ColorRect
@export var shadow: ColorRect
@export var outline: ColorRect

@onready var editor_settings: EditorSettings = EditorInterface.get_editor_settings()

var base_color: Color
var accent_color: Color

func GetHint(color: Color, amount: float) -> Color:
	return Color(color.r * amount, color.g * amount, color.b * amount, 1.0)

func _ready() -> void:
	editor_settings.settings_changed.connect(SetColor)
	SetColor()

func SetColor() -> void:
	base_color = editor_settings.get("interface/theme/base_color")
	accent_color = editor_settings.get("interface/theme/accent_color")
	
	top.color = base_color
	bottom.color = GetHint(base_color, 0.75)
	highlight.color = accent_color
	shadow.color = GetHint(base_color, 0.6)
	outline.color = GetHint(base_color, 0.5)
