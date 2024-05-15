@tool
extends Control

@export var top: ColorRect
@export var bottom: ColorRect
@export var tab_container: TabContainer
@export var built_in_container: VBoxContainer
@export var add_on_container: VBoxContainer

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
	
	var tab_selected: StyleBoxFlat = tab_container.get("theme_override_styles/tab_selected")
	var tab_hovered: StyleBoxFlat = tab_container.get("theme_override_styles/tab_hovered")
	var tab_unselected: StyleBoxFlat = tab_container.get("theme_override_styles/tab_unselected")
	
	top.color = base_color
	bottom.color = GetHint(base_color, 0.75)
	tab_selected.bg_color = base_color
	tab_selected.border_color = accent_color
	tab_hovered.bg_color = GetHint(base_color, 1.25)
	tab_hovered.border_color = accent_color
	tab_unselected.bg_color = GetHint(base_color,  0.6)
	
	add_on_container.child_entered_tree.connect(ChangeSceneColor)
	
	for built_in in built_in_container.get_children():
		if built_in is HBoxContainer:
			ChangeSceneColor(built_in)
	
	for add_on in add_on_container.get_children():
		if add_on is HBoxContainer:
			ChangeSceneColor(add_on)

func ChangeSceneColor(scene) -> void:
	if scene is HBoxContainer:
		scene.get_node("Margin/Info/Icon").modulate = accent_color
